package cz.fit.cvut.wrzecond.agapesongs.dto

/**
 * Data transfer object for role
 * @property id unique identifier of role
 * @property level text representation of user role
 */
data class RoleReadDTO (override val id: Int, val level: String) : IReadDTO
