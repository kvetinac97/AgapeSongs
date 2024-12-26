package cz.fit.cvut.wrzecond.agapesongs.dto

/**
 * Data transfer object for user authentication
 * @property id unique identifier of logged user
 * @property loginSecret login secret of logged user
 * @property name name of logged user
 */
data class UserLoginDTO (val id: Int, val loginSecret: String, val email: String, val name: String)

/**
 * Data transfer object for user in band members list
 * @property id unique identifier of user
 * @property email email of user
 * @property name name of user
 * @property bands list of band memberships of user
 */
data class UserReadDTO (override val id: Int, val email: String, val name: String,
                        val bands: List<BandMemberReadDTO>) : IReadDTO

/**
 * Data transfer object for user creation
 * @property email email of newly created user
 * @property name name of newly created user
 */
data class UserCreateDTO (val email: String, val name: String) : ICreateDTO
