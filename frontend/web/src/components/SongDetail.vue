<script setup>
import { onMounted, inject, provide, watch, ref } from 'vue'

import * as Nav from '@/plugins/nav'
import api from '@/plugins/api'
import { useUserStore } from '@/plugins/store'
import router from '@/plugins/router'

const appState = inject('appState')
const props = defineProps(['songBookId', 'songId'])
const song = ref(null)
const playlist = ref(null)
const userStore = useUserStore()

const keyTranspose = (keyPosition, steps, keys) => keys[(((keyPosition + steps) % 12) + 12) % 12]
const playlistPosition = () => {
  if (!playlist.value || !song.value) return -1
  return playlist.value.indexOf(song.value.id)
}

const playlistPush = (move) => {
  const path = new Nav.SongDetail(props.songBookId, {id: playlist.value[playlistPosition() + move], name: "", displayId: -1}).routerPath()
  router.push(path)
}

const transpose = (chords) => {
  const capo = userStore.capos[song.value.id]
  if (chords === null) return null
  const original = chords.split(" ")

  const positions = {
    "C": 0, "C_SHARP": 1, "D_FLAT": 1, "D": 2,
    "D_SHARP": 3, "E_FLAT": 3, "E": 4, "F_FLAT": 4,
    "E_SHARP": 5, "F": 5, "F_SHARP": 6, "G_FLAT": 6,
    "G": 7, "G_SHARP": 8, "A_FLAT": 8, "A": 9,
    "A_SHARP": 10, "B_FLAT": 10, "B": 11, "C_FLAT": 11
  };
  const positionsL = {
    "C": 0, "C#": 1, "Db": 1, "D#": 3, "D": 2,
    "Eb": 3, "E": 4, "E#": 5, "Fb": 4,
    "F#": 6, "F": 5, "Gb": 6, "G#": 8,
    "G": 7, "Ab": 8, "A": 9, "A#": 10,
    "B": 10, "H": 11, "Cb": 11
  };

  const songKeyPosition = positions[song.value.key]
  const flats = ['C', 'D_FLAT', 'D', 'E_FLAT', 'E', 'F', 'G_FLAT', 'G', 'A_FLAT', 'A', 'B_FLAT', 'B']
  const flatsL = ['C', 'Db', 'D', 'Eb', 'E', 'F', 'Gb', 'G', 'Ab', 'A', 'B', 'H']
  const sharpsL = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'B', 'H']

  const useFlats = ['F', 'B_FLAT', 'E_FLAT', 'A_FLAT']
      .includes(flats[songKeyPosition])
  const keys = useFlats ? flatsL : sharpsL

  const transposed = original.map((chord) => {
    for (let key in positionsL) {
      const keyTransposed = keyTranspose(positionsL[key], capo, keys)
      if (chord.replace("(", "").startsWith(key))
        return [chord, chord.replace(key, keyTransposed)]
    }
    return [chord, chord]
  })

  let skip = 0
  const result = transposed.map((val) => {
    let [originalStr, transposedStr] = val
    // Skip empty strings
    if (skip > 0 && transposedStr.length === 0) {
      skip -= 1
      return null
    }

    // OK, transposition did not change number of characters
    if (originalStr.length === transposedStr.length)
      return transposedStr

    // Number of characters is now shorter, add space
    if (transposedStr.length < originalStr.length)
      return `${transposedStr} `

    // Number of characters is now longer, remove space if we can
    skip += 1
    return transposedStr
  }).filter((r) => r !== null)

  return result.join(' ') + ' '
}

String.prototype.fill = function(maxCharacters) {
  if (this.length >= maxCharacters) {
    return this
  } else {
    return this + " ".repeat(maxCharacters - this.length)
  }
}

const lastSpaceIndex = (str) => {
  let index = str.lastIndexOf(' ');
  return index === -1 ? null : index;
}

const findSplitPosition = (textPrefix, chordPrefix) => {
  let chordIndex = lastSpaceIndex(chordPrefix)
  if (chordIndex === null) return null
  let textIndex = lastSpaceIndex(textPrefix)
  if (textIndex === null) return null

  // Move positions as long as we can
  while (chordIndex !== textIndex) {
    if (chordIndex < textIndex) {
      textIndex = lastSpaceIndex(textPrefix.substring(0, chordIndex + 1))
      if (textIndex === null) break
    }
    if (textIndex < chordIndex) {
      chordIndex = lastSpaceIndex(chordPrefix.substring(0, textIndex + 1))
      if (chordIndex === null) break
    }
  }

  // If both positions are same, we finished successfully
  return (textIndex === chordIndex) ? textIndex : null
}

const divide = (line, maxCharacters) => {
  const chords = line.chords ?? ""
  const text = line.text

  // No need to cut
  if (text.length <= maxCharacters || isNaN(maxCharacters) || maxCharacters <= 5)
    return [line]

  // Fill chords and text with spaces until `maxCharacters`
  const chordsFill = chords.fill(maxCharacters)
  const chordsPref = chordsFill.substring(0, maxCharacters)
  const textFill = text.fill(maxCharacters)
  const textPref = textFill.substring(0, maxCharacters)

  // Find position
  const position = findSplitPosition(textPref, chordsPref)
  const prefixEnd = position ?? maxCharacters
  const suffixStart = position !== null && position !== undefined ? position + 1 : maxCharacters

  // Return first part and recursively split the rest
  return [{
    id: line.id + '_1',
    chords: chords.length === 0 ? null : chordsFill.substring(0, prefixEnd),
    text: textFill.substring(0, prefixEnd)
  }].concat(divide(
      {
        id: line.id + '_2',
        chords: chords.length === 0 ? null : chordsFill.substring(suffixStart),
        text: textFill.substring(suffixStart)
      }, maxCharacters
  ))
}

const transformLines = (lines, textSize) => lines.flatMap((l) => divide(l, document.documentElement.clientWidth / textSize * 1.5))

const reload = async () => {
  playlist.value = (await api.fetchPlaylist(userStore.user.bandId)).songs
  api.songBookList()
      .then((result) => {
        song.value = result.find((sb) => sb.id == props.songBookId)?.songs?.find((song) => song.id == props.songId)
        if (!song.value) {
          for (let sb of result) {
            let sg = sb.songs.find((song) => song.id == props.songId)
            if (sg) {
              song.value = sg
              break
            }
          }
        }

        song.value.originalText = song.value.text
        song.value.text = transformLines(song.value.text, userStore.songSizes[song.value.id])
        userStore.songSizes[song.value.id] = userStore.songSizes[song.value.id] ?? 24
        userStore.capos[song.value.id] = userStore.capos[song.value.id] ?? song.value.capo
        appState.value.navigation = [new Nav.SongBookList(), new Nav.SongDetail(props.songBookId, song.value)]
      })
}
onMounted(async () => {
  await reload()
})
provide('reload', reload)

watch(props, async () => await reload())
watch(userStore.songSizes, () => {
  song.value.text = transformLines(song.value.originalText, userStore.songSizes[song.value.id])
})
</script>

<template>
  <div class="song px-2 py-3" v-if="song">
    <div class="line" :style="{fontSize: userStore.songSizes[song.id] + 'px'}" v-for="line in song.text" :key="line.id">
      <span class="chord" style="color: red; white-space: break-spaces" v-if="line.chords">{{ ' ' + transpose(line.chords) }}</span>
      <span class="lyrics" style="white-space: break-spaces">{{ ' ' + line.text }}</span>
    </div>
  </div>
  <v-layout-item v-if="song" model-value position="bottom" class="d-flex justify-end text-end" size="100">
    <div class="d-flex flex-row">
      <v-btn class="me-4" color="primary" icon="mdi-arrow-left"
             @click="() => playlistPush(-1)" v-if="playlistPosition() > 0" />
      <v-expand-transition>
        <div class="d-flex flex-column" v-if="!userStore.bottomHidden">
          <v-slider :label="`Capo: ${userStore.capos[song.id]}`" min="-12" max="12" step="1" color="primary"
                    show-ticks hide-details class="slider-width-auto me-8" v-model="userStore.capos[song.id]" />
          <v-slider label="Text" min="10" max="64" color="primary" class="slider-width-auto"
                    hide-details v-model="userStore.songSizes[song.id]" />
        </div>
      </v-expand-transition>
      <v-btn class="me-4" color="primary" icon="mdi-arrow-right"
             @click="() => playlistPush(1)" v-if="playlistPosition() !== -1 && playlistPosition() + 1 < playlist.length" />
      <v-btn class="me-4" color="primary" @click="userStore.bottomHidden = !userStore.bottomHidden"
             :icon="userStore.bottomHidden ? 'mdi-chevron-up' : 'mdi-chevron-down'" />
    </div>
  </v-layout-item>
</template>

<style scoped>
.song {
  display: flex;
  flex-direction: column;
  white-space: pre-wrap;
}

.line {
  font-family: monospace;
  display: flex;
  flex-direction: column;
}

.chord {
  margin-right: 10px; /* Adjust spacing between chord and lyrics */
}

.lyrics {
  white-space: pre; /* Preserve line breaks */
}

.slider-width-auto {
  width: 250px;
}
</style>