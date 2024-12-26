package cz.fit.cvut.wrzecond.agapesongs.entity

/**
 * Data transfer object for band list
 * @property id unique identifier of band
 * @property name band name
 * @property members list of band members
 */
data class Band (override val id: Int, val name: String, val members: List<BandMember>) : IEntity
