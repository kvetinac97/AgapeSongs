package cz.fit.cvut.wrzecond.agapesongs.entity

/**
 * Data transfer object for role
 * @property id unique identifier of role
 * @property level text representation of user role
 */
data class Role (override val id: Int, val level: String) : IEntity
