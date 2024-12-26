package cz.fit.cvut.wrzecond.agapesongs.entity

/**
 * Data transfer object for song book list
 * @property id unique identifier of song book
 * @property name song book name
 * @property band data transfer object of band which owns this song book
 * @property songs list of songs in the song book
 */
data class SongBook (override val id: Int, val name: String, val band: Band,
                     val songs: List<Song>) : IEntity
