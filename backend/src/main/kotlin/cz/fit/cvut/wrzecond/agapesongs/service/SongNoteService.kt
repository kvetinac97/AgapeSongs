package cz.fit.cvut.wrzecond.agapesongs.service

import cz.fit.cvut.wrzecond.agapesongs.dto.*
import cz.fit.cvut.wrzecond.agapesongs.entity.Song
import cz.fit.cvut.wrzecond.agapesongs.entity.SongNote
import cz.fit.cvut.wrzecond.agapesongs.entity.User
import cz.fit.cvut.wrzecond.agapesongs.repository.SongNoteRepository
import cz.fit.cvut.wrzecond.agapesongs.repository.SongRepository
import cz.fit.cvut.wrzecond.agapesongs.repository.UserRepository
import org.springframework.data.crossstore.ChangeSetPersister
import org.springframework.http.HttpStatus
import org.springframework.stereotype.Service
import org.springframework.web.server.ResponseStatusException
import java.sql.Timestamp
import java.time.Instant

@Service
class SongNoteService (override val repository: SongNoteRepository, userRepository: UserRepository,
                       val songRepository: SongRepository) : IServiceBase<SongNote> (repository, userRepository) {

    /**
     * Function to update song note on given song
     * @param songBookId identifier of song book in which is song to be edited
     * @param songId identifier of song to which note will be saved
     * @param dto data transfer object containing updated song data
     * @param user identification object for authenticating currently logged user
     * @return SongNoteReadDTO of saved song note
     * @throws ResponseStatusException on failure
     */
    fun putSongNote (songBookId: Int, songId: Int, dto: SongNoteUpdateDTO, user: UserReadDTO?) = tryCatch {
        val userEntity = getUser(user)
        val song = songRepository.getById(songId)
        if (song.songBook.id != songBookId) throw ChangeSetPersister.NotFoundException()

        val note = repository.getBySongAndUser(song, userEntity) ?: dto.toEntity(song, userEntity)
        if (!note.canEdit(userEntity)) throw ResponseStatusException(HttpStatus.FORBIDDEN)
        saveAndFlush(note.merge(dto)).toDTO()
    }

    // === HELPER METHODS ===
    private fun SongNote.toDTO () = SongNoteReadDTO(id, notes, capo, lastEdit)
    private fun SongNoteUpdateDTO.toEntity (song: Song, user: User) = SongNote(
        song, user,
        notes ?: throw NullPointerException(),
        capo ?: throw NullPointerException(),
        Timestamp.from(Instant.now())
    )
    private fun SongNote.merge (dto: SongNoteUpdateDTO) = copy(
        notes = dto.notes ?: notes,
        capo = dto.capo ?: capo,
        lastEdit = Timestamp.from(Instant.now())
    )
    // === HELPER METHODS ===

}
