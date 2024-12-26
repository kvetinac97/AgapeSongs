package cz.fit.cvut.wrzecond.agapesongs.entity

/**
 * Data transfer object for line of song
 * @property id unique identifier of song line
 * @property chords chords associated with given text line, null if line has no chords
 * @property text one line of song text
 */
data class SongLine (val id: String, val chords: String?, val text: String)
