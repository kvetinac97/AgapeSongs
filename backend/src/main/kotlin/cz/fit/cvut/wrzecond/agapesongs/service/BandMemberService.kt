package cz.fit.cvut.wrzecond.agapesongs.service

import cz.fit.cvut.wrzecond.agapesongs.dto.*
import cz.fit.cvut.wrzecond.agapesongs.entity.Band
import cz.fit.cvut.wrzecond.agapesongs.entity.BandMember
import cz.fit.cvut.wrzecond.agapesongs.entity.Role
import cz.fit.cvut.wrzecond.agapesongs.entity.User
import cz.fit.cvut.wrzecond.agapesongs.repository.BandMemberRepository
import cz.fit.cvut.wrzecond.agapesongs.repository.BandRepository
import cz.fit.cvut.wrzecond.agapesongs.repository.RoleRepository
import org.springframework.data.crossstore.ChangeSetPersister
import org.springframework.http.HttpStatus
import org.springframework.stereotype.Service
import org.springframework.web.server.ResponseStatusException

@Service
class BandMemberService (override val repository: BandMemberRepository, val roleRepository: RoleRepository,
                         val bandRepository: BandRepository, val userService: UserService)
    : IServiceBase<BandMember>(repository, userService.repository) {

    /**
     * Function to add user defined in dto to band with given identifier
     * @param bandId identifier of band to add the user to
     * @param dto band membership creation data
     * @param userDto identification object for authenticating currently logged user
     * @return BandMemberDTO of newly created membership on success
     * @throws ResponseStatusException on failure
     */
    fun createMember (bandId: Int, dto: BandMemberCreateDTO, userDto: UserReadDTO?) = tryCatch {
        val band = bandRepository.getById(bandId)
        if (!band.canEdit(getUser(userDto))) throw ResponseStatusException(HttpStatus.FORBIDDEN)
        val user = userService.getOrCreate(dto.email, dto.name)
        saveAndFlush(dto.toEntity(band, user)).toDTO()
    }

    /**
     * Function to change role of band member
     * @param bandId identifier of band in which to change membership
     * @param memberId identifier of membership to change
     * @param dto band membership change data
     * @param userDto identification object for authenticating currently logged user
     * @return BandMemberDTO of updated membership on success
     * @throws ResponseStatusException on failure
     */
    fun changeMember (bandId: Int, memberId: Int, dto: BandMemberUpdateDTO, userDto: UserReadDTO?) = tryCatch {
        val member = getById(memberId)
        if (!member.band.canEdit(getUser(userDto))) throw ResponseStatusException(HttpStatus.FORBIDDEN)
        if (member.band.id != bandId) throw ChangeSetPersister.NotFoundException()
        saveAndFlush(member.merge(dto)).toDTO()
    }

    /**
     * Function to delete membership in given band
     * @param bandId identifier of band in which to delete membership
     * @param memberId identifier of membership to delete
     * @param userDto identification object for authenticating currently logged user
     * @throws ResponseStatusException on failure
     */
    fun deleteMember (bandId: Int, memberId: Int, userDto: UserReadDTO?) = tryCatch {
        val member = getById(memberId)
        val user = getUser(userDto)
        if (member.user.id != user.id && !member.band.canEdit(user)) throw ResponseStatusException(HttpStatus.FORBIDDEN) // allow self-delete
        if (member.band.id != bandId) throw ChangeSetPersister.NotFoundException()
        delete(member)
    }

    // === HELPER METHODS ===
    private fun BandMember.toDTO () = BandMemberReadDTO(id, BandReadDTO(band.id,
        band.name, band.secret, emptyList()), user.toDTO(), role.toDTO())
    private fun User.toDTO () = UserReadDTO(id, email, name, emptyList())
    private fun Role.toDTO () = RoleReadDTO(id, level.name)

    private fun BandMember.merge (dto: BandMemberUpdateDTO) = copy (
        role = roleRepository.getById(dto.roleId)
    )
    private fun BandMemberCreateDTO.toEntity (band: Band, user: User) = BandMember (
        band, user, roleRepository.getById(roleId)
    )
    // === HELPER METHODS ===

}