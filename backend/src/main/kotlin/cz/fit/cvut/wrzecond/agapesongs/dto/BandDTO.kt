package cz.fit.cvut.wrzecond.agapesongs.dto

/**
 * Data transfer object for band list
 * @property id unique identifier of band
 * @property name band name
 * @property members list of band members
 */
data class BandReadDTO (override val id: Int, val name: String, val secret: String,
                        val members: List<BandMemberReadDTO>) : IReadDTO

/**
 * Data transfer object used to change band name
 * @property name new name of band being changed
 * @property secret secret code for band join
 */
data class BandUpdateDTO (val name: String?, val secret: String?) : IUpdateDTO

/**
 * Data transfer object used for creating new band
 * @property name name of newly created band
 * @property secret secret code for joining band
 */
data class BandCreateDTO (val name: String, val secret: String = "") : ICreateDTO

/**
 * Special data transfer object for joining band from QR code
 * @property id id of band being joined
 * @property secret secret code for joining band
 */
data class BandJoinDTO (val id: Int, val secret: String)
