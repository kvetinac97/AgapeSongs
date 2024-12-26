package cz.fit.cvut.wrzecond.agapesongs.entity

/**
 * Data transfer object for user in band members list
 * @property id unique identifier of user
 * @property email email of user
 * @property name name of user
 * @property bands list of band memberships of user
 */
data class User (override val id: Int, val email: String, val name: String,
                 val bands: List<BandMember>) : IEntity
