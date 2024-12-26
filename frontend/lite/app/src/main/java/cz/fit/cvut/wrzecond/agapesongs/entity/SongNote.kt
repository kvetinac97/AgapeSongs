package cz.fit.cvut.wrzecond.agapesongs.entity

import java.sql.Timestamp

/**
 * Data transfer object describing song note
 * @property id unique identifier of song note
 * @property notes personal notes text
 * @property capo personal transposition of song
 * @property lastEdit time of last song note change
 */
data class SongNote (override val id: Int, val notes: String, val capo: Int, val lastEdit: Timestamp) : IEntity
