package cz.fit.cvut.wrzecond.agapesongs.service

import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import cz.fit.cvut.wrzecond.agapesongs.dto.*
import cz.fit.cvut.wrzecond.agapesongs.entity.*
import cz.fit.cvut.wrzecond.agapesongs.repository.*
import org.springframework.http.HttpStatus
import org.springframework.stereotype.Service
import org.springframework.web.server.ResponseStatusException
import java.text.Collator
import java.util.Locale

@Service
class BandService (override val repository: BandRepository, private val roleRepository: RoleRepository,
                   private val songRepository: SongRepository, private val userRepository: UserRepository,
                   private val bandMemberRepository: BandMemberRepository)
    : IServiceImpl<Band, BandReadDTO, BandCreateDTO, BandUpdateDTO>(repository, userRepository) {

    /** Find all bands in database sorted by name in czech locale */
    override fun findAll (user: UserReadDTO?) = super.findAll(user).sortedWith(
        compareBy(Collator.getInstance(Locale("cs_CZ"))) { it.name }
    )

    /** Get band with given name and secret */
    fun existsWithSecret (secret: String) = tryCatch {
        repository.getBySecret(secret) != null
    }

    /**
     * Function to try to join given band
     * @param dto the DTO containing name and secret for joining
     * @param userDto user which should join the band
     * @param role which role should the new user have
     */
    fun join (dto: BandCreateDTO, userDto: UserReadDTO?, role: RoleLevel) : BandReadDTO = tryCatch {
        val band = repository.getBySecret(dto.secret) ?: throw ResponseStatusException(HttpStatus.NOT_FOUND)
        val user = userDto?.email?.let { userRepository.getByEmail(it) } ?: throw ResponseStatusException(HttpStatus.UNAUTHORIZED)
        val singer = roleRepository.getById(role.ordinal + 1)
        // name does not match / already in band
        if (band.name != dto.name || band.members.any { member -> member.user.id == user.id })
            throw ResponseStatusException(HttpStatus.BAD_REQUEST)
        val member = bandMemberRepository.saveAndFlush(BandMember(band, user, singer)) // add user
        band.copy(members = band.members + member).toDTO()
    }

    /**
     * Function to add user to band
     * @param dto the DTO containing band id and secret for joining
     * @param userDto user which should join the band
     */
    fun joinWithId (dto: BandJoinDTO, userDto: UserReadDTO?) = tryCatch {
        val band = repository.getById(dto.id)
        val user = userDto?.email?.let { userRepository.getByEmail(it) } ?: throw ResponseStatusException(HttpStatus.UNAUTHORIZED)
        val singer = roleRepository.getById(RoleLevel.SINGER.ordinal + 1)
        // secret does not match / already in band
        if (band.secret != dto.secret || band.members.any { member -> member.user.id == user.id })
            throw ResponseStatusException(HttpStatus.BAD_REQUEST)
        val member = bandMemberRepository.saveAndFlush(BandMember(band, user, singer))
        band.copy(members = band.members + member).toDTO()
    }

    /**
     * Function to get playlist of given band
     * @param id identifier of band from which playlist will be fetched
     * @param user identification object for authenticating currently logged user
     * @return PlaylistDTO containing identifiers of songs in band playlist
     * @throws ResponseStatusException on failure
     */
    fun getPlaylist (id: Int, user: UserReadDTO?) = tryCatch {
        val band = getBandOrThrow(id, user) { canView(it) }
        val intArrayType = object: TypeToken<List<Int>>(){}.type
        val songIds: List<Int> = Gson().fromJson(band.playlist, intArrayType)
        val songs = songRepository.findByIds(songIds)
        PlaylistDTO(songIds.mapNotNull { songId -> songs.find { song -> song.id == songId }?.id })
    }

    /**
     * Function to save playlist of given band
     * @param id identifier of band to which playlist will be saved
     * @param playlist playlist object containing song ids to be saved
     * @param user identification object for authenticating currently logged user
     * @return PlaylistDTO containing identifiers of songs in band playlist
     * @throws ResponseStatusException on failure
     */
    fun putPlaylist (id: Int, playlist: PlaylistDTO, user: UserReadDTO?) = tryCatch {
        val band = getBandOrThrow(id, user) { canEdit(it) }
        val songs = songRepository.findByIds(playlist.songs)
        val matchedSongs = playlist.songs.mapNotNull { songId -> songs.find { song -> song.id == songId }?.id }
        val newBand = band.copy(playlist = Gson().toJson(matchedSongs))
        repository.saveAndFlush(newBand)
        PlaylistDTO(matchedSongs)
    }

    // === INTERFACE METHOD IMPLEMENTATION ===
    override fun Band.toDTO () = BandReadDTO(id, name, secret, members.map { it.toDTO() })
    override fun BandCreateDTO.toEntity () = Band(name, secret, "[]", emptyList(), emptyList())
    override fun Band.merge (dto: BandUpdateDTO) = Band (
        dto.name ?: name, dto.secret ?: secret,
        playlist, members, songBooks,
        id
    )

    override fun create(dto: BandCreateDTO, user: UserReadDTO?) = repository.saveAndFlush(dto.toEntity()).toDTO()
    // === INTERFACE METHOD IMPLEMENTATION ===

    // === HELPER METHODS ===
    private fun BandMember.toDTO () = BandMemberReadDTO(id, BandReadDTO(band.id,
        band.name, band.secret, emptyList()), user.toDTO(), role.toDTO())
    private fun User.toDTO () = UserReadDTO(id, email, name, emptyList())
    private fun Role.toDTO () = RoleReadDTO(id, level.name)
    // === HELPER METHODS ===

    // === PRIVATE HELPERS ===
    private fun getBandOrThrow(id: Int, user: UserReadDTO?, check: Band.(User) -> Boolean) = tryCatch {
        val band = getById(id)
        val userEntity = user?.let { userRepository.getByEmail(it.email) } ?: throw ResponseStatusException(HttpStatus.UNAUTHORIZED)
        if (!check(band, userEntity)) throw ResponseStatusException(HttpStatus.FORBIDDEN)
        band
    }
    // === PRIVATE HELPERS ===

}
