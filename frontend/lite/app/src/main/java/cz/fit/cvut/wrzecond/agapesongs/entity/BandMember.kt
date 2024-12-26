package cz.fit.cvut.wrzecond.agapesongs.entity

/**
 * Data transfer object for band members
 * @property id unique identifier of band membership
 * @property band data transfer object for band
 * @property user data transfer object for user
 * @property role data transfer object for role
 */
data class BandMember (override val id: Int, val band: Band,
                       val user: User, val role: Role) : IEntity
