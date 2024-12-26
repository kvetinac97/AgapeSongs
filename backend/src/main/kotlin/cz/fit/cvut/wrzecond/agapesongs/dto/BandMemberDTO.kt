package cz.fit.cvut.wrzecond.agapesongs.dto

/**
 * Data transfer object for band members
 * @property id unique identifier of band membership
 * @property band data transfer object for band
 * @property user data transfer object for user
 * @property role data transfer object for role
 */
data class BandMemberReadDTO (override val id: Int, val band: BandReadDTO,
                              val user: UserReadDTO, val role: RoleReadDTO) : IReadDTO

/**
 * Data transfer object used to add new band member
 * @property email band member email
 * @property name band member name
 * @property roleId band member role identifier
 */
data class BandMemberCreateDTO (val email: String, val name: String, val roleId: Int)

/**
 * Data transfer object used for updating band member role
 * @property roleId identifier of new role in membership
 */
data class BandMemberUpdateDTO (val roleId: Int)
