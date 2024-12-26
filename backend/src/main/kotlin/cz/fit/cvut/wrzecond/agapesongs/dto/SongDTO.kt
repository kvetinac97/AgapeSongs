package cz.fit.cvut.wrzecond.agapesongs.dto

import java.sql.Timestamp

/**
 * Data transfer object for song list in song book
 * @property id unique identifier of song
 * @property songBook data transfer object of song book which contains this song
 * @property name song name
 * @property text array of song text and chord lines
 * @property key song key
 * @property bpm song bpm
 * @property beat song beat
 * @property capo default transposition used for song
 * @property lastEdit time of last song change
 * @property displayId song number in song book (null if song has no number)
 * @property note user private note on given song (null if not any)
 */
data class SongReadDTO (override val id: Int, val songBook: SongBookReadDTO, val name: String,
                        val text: List<SongLineReadDTO>, val key: SongKey, val bpm: Int, val beat: SongBeat,
                        val capo: Int, val lastEdit: Timestamp, val displayId: Int?, val note: SongNoteReadDTO?) : IReadDTO

/**
 * Data transfer object for line of song
 * @property id unique identifier of song line
 * @property chords chords associated with given text line, null if line has no chords
 * @property text one line of song text
 */
data class SongLineReadDTO (val id: String, val chords: String?, val text: String)

/**
 * Data transfer object for creating song
 * @property name name of newly created song
 * @property text text of newly created song in OpenSong format
 * @property key key of newly created song
 * @property bpm bpm of newly created song
 * @property beat beat of newly created song TODO remove optional version (currently because of compatibility)
 * @property capo default transposition of newly created song
 * @property songBookId song book which will contain the newly created song
 * @property displayId number of newly created song in song book (null if song has no number)
 */
data class SongCreateDTO (val name: String, val text: String, val key: SongKey, val bpm: Int, val beat: SongBeat?,
                          val capo: Int, val songBookId: Int, val displayId: Int?) : ICreateDTO

/**
 * Data transfer object for updating song
 * @property name new name of song
 * @property text new text of song in OpenSong format
 * @property key new key of song
 * @property bpm new bpm of song
 * @property beat new beat of song
 * @property capo new default transposition of song
 * @property songBookId new song book to which transfer this song
 * @property displayId new song number in song book (null if song has no number)
 */
data class SongUpdateDTO (val name: String?, val text: String?, val key: SongKey?, val bpm: Int?, val beat: SongBeat?,
                          val capo: Int?, val songBookId: Int?, val displayId: Int?) : IUpdateDTO

/**
 * Enum class representing possible song keys
 */
enum class SongKey {
    C, C_SHARP, D_FLAT, D, D_SHARP, E_FLAT, E, F, F_SHARP,
    G_FLAT, G, G_SHARP, A_FLAT, A_SHARP, A, B_FLAT, B
}

/**
 * Enum class representing possible song beats
 */
enum class SongBeat {
    TWO_HALVES,
    TWO_FOURTHS, THREE_FOURTHS, FOUR_FOURTHS, FIVE_FOURTHS, SIX_FOURTHS,
    THREE_EIGHTS, FOUR_EIGHTS, FIVE_EIGHTS, SIX_EIGHTS, SEVEN_EIGHTS, EIGHT_EIGHTS,
}
