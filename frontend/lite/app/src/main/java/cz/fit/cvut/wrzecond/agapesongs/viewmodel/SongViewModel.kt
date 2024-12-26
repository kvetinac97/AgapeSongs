package cz.fit.cvut.wrzecond.agapesongs.viewmodel

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import cz.fit.cvut.wrzecond.agapesongs.entity.SongKey
import cz.fit.cvut.wrzecond.agapesongs.entity.SongLine
import cz.fit.cvut.wrzecond.agapesongs.entity.Song
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.launch

class SongViewModel(application: Application): AndroidViewModel(application) {
    // Properties
    val song = MutableStateFlow<Song?>(null)
    val fontSize = MutableStateFlow(20)
    val maxCharacters = MutableStateFlow(0)
    val capo = MutableStateFlow(0)

    init {
        viewModelScope.launch {
            fontSize.collect { fontSize ->
                val song = song.value ?: return@collect
                val preferences = getApplication<Application>().getSharedPreferences("SONG_${song.id}", Application.MODE_PRIVATE)
                preferences.edit().putInt("FONT_SIZE", fontSize).apply()
            }
        }
        viewModelScope.launch {
            capo.collect { capo ->
                val song = song.value ?: return@collect
                val preferences = getApplication<Application>().getSharedPreferences("SONG_${song.id}", Application.MODE_PRIVATE)
                preferences.edit().putInt("CAPO", capo).apply()
            }
        }
    }

    fun setSong(song: Song) {
        val preferences = getApplication<Application>().getSharedPreferences("SONG_${song.id}", Application.MODE_PRIVATE)
        this.song.value = song
        fontSize.value = preferences.getInt("FONT_SIZE", 20)
        capo.value = preferences.getInt("CAPO", song.capo)
    }

    fun transpose(capo: Int, chordsNullable: String?) : String? {
        val chords = chordsNullable ?: return null
        val song = song.value ?: return null
        val original = chords.split(' ')
        val songKeyPosition = (((song.key.keyPosition + capo) % 12) + 12) % 12

        val useFlats = listOf(SongKey.F, SongKey.B_FLAT, SongKey.E_FLAT, SongKey.A_FLAT)
            .contains(SongKey.flats[songKeyPosition])
        val keys = if (useFlats) SongKey.flats else SongKey.sharps

        val transposed = original.map { chord ->
            SongKey.values().forEach { key ->
                val keyTransposed = key.transpose(capo, keys)
                if (chord.replace("(", "").startsWith(key.localized)) {
                    return@map chord to chord.replace(key.localized, keyTransposed.localized)
                }
            }
            return@map chord to chord
        }

        var skip = 0
        val result = transposed.mapNotNull { (originalStr, transposedStr) ->
            // Skip empty strings
            if (skip > 0 && transposedStr.isEmpty()) {
                skip -= 1
                return@mapNotNull null
            }

            // OK, transposition did not change number of characters
            if (originalStr.length == transposedStr.length)
                return@mapNotNull transposedStr

            // Number of characters is now shorter, add space
            if (transposedStr.length < originalStr.length)
                return@mapNotNull "$transposedStr "

            // Number of characters is now longer, remove space if we can
            skip += 1
            return@mapNotNull transposedStr
        }

        return result.joinToString(separator = " ")
    }

    fun textWithInformation(maxCharacters: Int) : List<SongLine> {
        val song = song.value ?: return emptyList()
        val bpmInformation = if (song.bpm == 0 || song.bpm == 999) emptyList() else listOf("🎵 ${song.bpm}")
        val capoInformation = if (song.capo == 0) emptyList() else listOf("capo ${song.capo}")
        val songInformation = bpmInformation + capoInformation
        val lines = if (songInformation.isEmpty()) song.text else
            listOf(SongLine(
                id = "songinfo",
                chords = null,
                text = songInformation.joinToString(separator = ", ")
            )) + song.text
        return lines.flatMap { divide(it, maxCharacters) }
    }

    fun changeSong(songs: List<Song>, i: Int) {
        val song = song.value ?: return
        val nowIndex = songs.indexOfFirst { it.id == song.id }
        val wantIndex = nowIndex + i
        if (wantIndex < 0 || wantIndex >= songs.size) return
        setSong(songs[wantIndex])
    }

    private fun divide(line: SongLine, maxCharacters: Int) : List<SongLine> {
        val chords = line.chords ?: ""
        val text = line.text

        // No need to cut
        if (text.length <= maxCharacters || maxCharacters <= 5)
            return listOf(line)

        // Fill chords and text with spaces until `maxCharacters`
        val chordsFill = chords.fill(maxCharacters)
        val chordsPref = chordsFill.substring(0, maxCharacters)
        val textFill = text.fill(maxCharacters)
        val textPref = textFill.substring(0, maxCharacters)

        // Find position
        val position = findSplitPosition(textPref, chordsPref)
        val prefixEnd = position ?: maxCharacters
        val suffixStart = position?.let { it + 1 } ?: maxCharacters

        // Return first part and recursively split the rest
        return listOf(SongLine(
            id = line.id + "_1",
            chords = if (chords.isEmpty()) null else chordsFill.substring(0, prefixEnd),
            text = textFill.substring(0, prefixEnd)
        )) + divide(
            SongLine(
                id = line.id + "_2",
                chords = if (chords.isEmpty()) null else chordsFill.substring(suffixStart),
                text = textFill.substring(suffixStart)
            ), maxCharacters
        )
    }

    /**
     * Finds the ideal split position for the two prefixes, that meets following requirements:
     * 1) both prefixes contain a space character at this position
     * 2) it is the furthest position meeting this requirement
     * if no such position exists, text is just cut in two halves disregarding spaces (represented by `nil`)
     */
    private fun findSplitPosition(textPrefix: String, chordPrefix: String) : Int? {
        var chordIndex = chordPrefix.lastSpaceIndex() ?: return null
        var textIndex = textPrefix.lastSpaceIndex() ?: return null

        // Move positions as long as we can
        while (chordIndex != textIndex) {
            if (chordIndex < textIndex)
                textIndex = textPrefix.substring(0, chordIndex + 1).lastSpaceIndex() ?: break
            if (textIndex < chordIndex)
                chordIndex = chordPrefix.substring(0, textIndex + 1).lastSpaceIndex() ?: break
        }

        // If both positions are same, we finished successfully
        return if (textIndex == chordIndex) textIndex else null
    }

    private fun String.lastSpaceIndex() =
        lastIndexOf(' ').let {
            if (it == -1) null else it
        }

    private fun String.fill (maxCharacters: Int) =
        if (length >= maxCharacters) this
        else this + " ".repeat(maxCharacters - length)
}
