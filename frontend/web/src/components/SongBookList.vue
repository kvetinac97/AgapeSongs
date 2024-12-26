<script setup>
import { onMounted, inject, ref } from 'vue'
import api from '@/plugins/api'
import * as Nav from '@/plugins/nav'
import { useUserStore } from '@/plugins/store'
import router from '@/plugins/router'

const searchText = ref('')
const songBooks = ref(null)
const userStore = useUserStore()
const appState = inject('appState')
const error = ref(null)

const reloadSongs = async (e = null) => {
  e?.stopPropagation()
  const playlist = await api.fetchPlaylist(userStore.user.bandId)
      .catch((err) => { error.value = `Chyba při načítání playlistu: ${err.message}` })
  api.songBookList()
      .then((result) => {
        const playlistSongs = playlist.songs.map((songId) => {
          for (let sb of result) {
            const searchedSong = sb.songs.find((song) => song.id === songId)
            if (!searchedSong) continue
            searchedSong.songbookId = sb.id
            return searchedSong
          }
          return undefined
        }).filter((song) => song)

        appState.value.navigation = [new Nav.SongBookList()]
        songBooks.value = [{id: -1, name: "Playlist", songs: playlistSongs}].concat(result)
      })
      .catch((err) => { error.value = `Chyba při načítání: ${err.message}` })
}
onMounted(reloadSongs)
</script>

<template>
  <v-card title="Zpěvníky">
    <v-text-field prepend-inner-icon="mdi-magnify" v-model="searchText" class="px-4" placeholder="Hledání" />
    <v-table v-if="songBooks">
      <tbody>
      <template v-for="sb in songBooks" :key="sb.id">
        <tr style="cursor: pointer" @click="userStore.shownSbs[sb.id] = !userStore.shownSbs[sb.id]">
          <th v-ripple.center>
            <div class="d-flex justify-space-between align-center" style="gap: 16px">
              <h3 class="ps-2">{{ sb.name }}</h3>
              <div>
                <v-btn class="me-2" variant="text" icon="mdi-reload" @click="reloadSongs" v-if="sb.id === -1" />
                <v-btn class="pe-2" variant="text" :icon="userStore.shownSbs[sb.id] ? 'mdi-chevron-up' : 'mdi-chevron-down'" />
              </div>
            </div>
          </th>
        </tr>
        <template v-if="userStore.shownSbs[sb.id]">
          <tr v-for="song in sb.songs.filter((sg) => sg.displayId === parseInt(searchText) || sg.name.toLowerCase().includes(searchText.toLowerCase()))" :key="song.id" style="cursor: pointer"
              @click="router.push(new Nav.SongDetail(song.songbookId ?? sb.id, song).routerPath())">
            <td class="px-8 d-flex flex-row align-center justify-space-between" v-ripple.center>
              <h4 style="font-weight: normal">{{ song.name }} <template v-if="song.displayId">({{ song.displayId }})</template></h4>
              <v-btn color="rgb(var(--v-theme-anchor))" variant="text" icon="mdi-arrow-right"></v-btn>
            </td>
          </tr>
        </template>
      </template>
      </tbody>
    </v-table>
    <v-card-item v-if="error">
      {{ error }}
    </v-card-item>
    <v-card-item class="flex justify-center" v-else-if="!songBooks">
      <v-progress-circular indeterminate="true" />
    </v-card-item>
  </v-card>
</template>

<style scoped>
</style>