package cz.fit.cvut.wrzecond.agapesongs.dto

/**
 * Data transfer object for song book list
 * @property id unique identifier of song book
 * @property name song book name
 * @property band data transfer object of band which owns this song book
 * @property songs list of songs in the song book
 */
data class SongBookReadDTO (override val id: Int, val name: String, val band: BandReadDTO,
                            val songs: List<SongReadDTO>) : IReadDTO

/**
 * Data transfer object for updating song book
 * @property name new song book name
 * @property bandId new band to which transfer membership of the song book
 */
data class SongBookUpdateDTO (val name: String?, val bandId: Int?) : IUpdateDTO

/**
 * Data transfer object for creating song book
 * @property name name of newly created song book
 * @property bandId band which will own the newly created song book
 */
data class SongBookCreateDTO (val name: String, val bandId: Int) : ICreateDTO
