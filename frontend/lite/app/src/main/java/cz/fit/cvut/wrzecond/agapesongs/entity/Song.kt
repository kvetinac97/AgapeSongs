package cz.fit.cvut.wrzecond.agapesongs.entity

import androidx.compose.ui.text.intl.Locale
import androidx.compose.ui.text.toLowerCase
import java.sql.Timestamp

/**
 * Data transfer object for song list in song book
 * @property id unique identifier of song
 * @property songBook data transfer object of song book which contains this song
 * @property name song name
 * @property text array of song text and chord lines
 * @property key song key
 * @property bpm song bpm
 * @property capo default transposition used for song
 * @property lastEdit time of last song change
 * @property displayId song number in song book (null if song has no number)
 * @property note user private note on given song (null if not any)
 */
data class Song (override val id: Int, val songBook: SongBook, val name: String,
                 val text: List<SongLine>, val key: SongKey, val bpm: Int, val capo: Int,
                 val lastEdit: Timestamp, val displayId: Int?, val note: SongNote?) : IEntity {

    fun matches(text: String) : Boolean {
        if (displayId != null && text == String.format("%03d", displayId)) return true
        if (name.toLowerCase(Locale.current).contains(text.toLowerCase(Locale.current))) return true
        return false
    }
}
