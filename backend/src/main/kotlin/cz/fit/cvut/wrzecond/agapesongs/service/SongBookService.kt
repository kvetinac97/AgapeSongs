package cz.fit.cvut.wrzecond.agapesongs.service

import cz.fit.cvut.wrzecond.agapesongs.dto.*
import cz.fit.cvut.wrzecond.agapesongs.entity.*
import cz.fit.cvut.wrzecond.agapesongs.repository.BandRepository
import cz.fit.cvut.wrzecond.agapesongs.repository.SongBookRepository
import cz.fit.cvut.wrzecond.agapesongs.repository.SongNoteRepository
import cz.fit.cvut.wrzecond.agapesongs.repository.UserRepository
import org.springframework.stereotype.Service
import java.text.Collator
import java.util.Locale

@Service
class SongBookService (override val repository: SongBookRepository, val songService: SongService,
                       userRepository: UserRepository, val songNoteRepository: SongNoteRepository,
                       val bandRepository: BandRepository)
    : IServiceImpl<SongBook, SongBookReadDTO, SongBookCreateDTO, SongBookUpdateDTO>(repository, userRepository) {

    /**
     * Find all song books in database sorted by name in czech locale
     * with songs sorted by name in czech locale and with added user notes
     */
    @Suppress("Deprecation")
    override fun findAll(user: UserReadDTO?) = tryCatch {
        val userEntity = getUser(user)
        val notes = songNoteRepository.findByUser(userEntity)

        val songBooks = repository.findByBands(userEntity.bands.map { it.band }).map { it.toDTO() }
        val czechCollator = Collator.getInstance(Locale("cs_CZ"))
        songBooks.map { songBook -> songBook.copy(
            songs = songBook.songs.map { song -> song.copy(
                note = notes.find { it.song.id == song.id }?.toDTO()
            )}.sortedWith(compareBy(czechCollator) { it.name })
        )}.sortedWith(compareBy(czechCollator) { it.name })
    }

    // === INTERFACE METHOD IMPLEMENTATION ===
    override fun SongBook.toDTO () : SongBookReadDTO = SongBookReadDTO(id, name, band.toDTO(), songs.map { it.toDTO() })
    override fun SongBookCreateDTO.toEntity () = SongBook(name, emptyList(), bandRepository.getById(bandId))
    override fun SongBook.merge (dto: SongBookUpdateDTO) = copy(
        name = dto.name ?: name,
        band = dto.bandId?.let { bandRepository.getById(it) } ?: band
    )
    // === INTERFACE METHOD IMPLEMENTATION ===

    // === HELPER METHODS ===
    private fun Song.toDTO () = SongReadDTO(id, songBook.copy(songs = emptyList()).toDTO(), name,
        songService.convertSongText(text), SongKey.valueOf(key), bpm, SongBeat.valueOf(beat), capo, lastEdit, displayId, null)
    private fun SongNote.toDTO () = SongNoteReadDTO(id, notes, capo, lastEdit)
    private fun Band.toDTO () = BandReadDTO(id, name, secret, members.map { it.toDTO() })

    private fun BandMember.toDTO () = BandMemberReadDTO(id, BandReadDTO(band.id,
        band.name, band.secret, emptyList()
    ), user.toDTO(), role.toDTO())
    private fun User.toDTO () = UserReadDTO(id, email, name, emptyList())
    private fun Role.toDTO () = RoleReadDTO(id, level.name)
    // === HELPER METHODS ===

}
