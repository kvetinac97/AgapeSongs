package cz.fit.cvut.wrzecond.agapesongs.service

import cz.fit.cvut.wrzecond.agapesongs.dto.*
import cz.fit.cvut.wrzecond.agapesongs.entity.*
import cz.fit.cvut.wrzecond.agapesongs.repository.BandRepository
import cz.fit.cvut.wrzecond.agapesongs.repository.UserRepository
import org.springframework.http.HttpStatus
import org.springframework.stereotype.Service
import org.springframework.web.server.ResponseStatusException
import kotlin.random.Random

@Service
class UserService (override val repository: UserRepository, private val bandRepository: BandRepository)
    : IServiceBase<User>(repository, repository) {

    /** Function to get user by login secret */
    fun getByLoginSecret (loginSecret: String)
        = repository.getByLoginSecret(loginSecret)?.toDTO()

    /** Function to get user with given email. If no user exists, creates one with given name */
    fun getOrCreate (email: String, name: String) = tryCatch {
        repository.getByEmail(email) ?: saveAndFlush(UserCreateDTO(email, name).toEntity())
    }

    /** Function to delete user */
    fun delete (id: Int, dto: UserReadDTO?) = tryCatch {
        if (dto == null || dto.id != id) throw ResponseStatusException(HttpStatus.BAD_REQUEST)

        // Update every band user was only leader of
        dto.bands.filter { it.role.level == RoleLevel.LEADER.name }.forEach { bandMember ->
            val band = bandRepository.getById(bandMember.band.id)
            // He was the only leader
            if (!band.members.any { it.role.level == RoleLevel.LEADER && it.user.id != id }) {
                if (band.songBooks.isEmpty())
                    bandRepository.delete(band) // no song books = delete the band
                else
                    bandRepository.saveAndFlush(band.updateSecret("")) // remove secret
            }
        }

        // Delete the user
        repository.deleteById(id)
    }

    // === HELPER METHODS ===
    private fun User.toDTO () = UserReadDTO(id, email, name, bands.map { it.toDTO() })
    private fun UserCreateDTO.toEntity () = User(generateLoginSecret(), email, name, emptyList(), emptyList())
    private fun generateLoginSecret () = (1..LOGIN_SECRET_LENGTH)
        .map { Random.nextInt(0, CHAR_POOL.size) }
        .map(CHAR_POOL::get)
        .joinToString("")
    private fun Band.updateSecret (secret: String) = Band(name, secret, playlist, members, songBooks, id)
    private fun BandMember.toDTO () = BandMemberReadDTO(id, band.toDTO(),
        UserReadDTO(user.id, user.email, user.name, emptyList()), role.toDTO())
    private fun Band.toDTO ()     = BandReadDTO(id, name, secret, emptyList())
    private fun Role.toDTO ()     = RoleReadDTO(id, level.name)
    // === HELPER METHODS ===

    companion object {
        private const val LOGIN_SECRET_LENGTH = 16
        private val CHAR_POOL = ('a'..'z') + ('A'..'Z') + ('0'..'9')
    }
}
