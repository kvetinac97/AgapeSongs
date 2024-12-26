package cz.fit.cvut.wrzecond.agapesongs.service

import cz.fit.cvut.wrzecond.agapesongs.dto.*
import cz.fit.cvut.wrzecond.agapesongs.entity.*
import cz.fit.cvut.wrzecond.agapesongs.repository.SongRepository
import cz.fit.cvut.wrzecond.agapesongs.repository.SongNoteRepository
import cz.fit.cvut.wrzecond.agapesongs.repository.UserRepository
import io.kotest.assertions.throwables.shouldThrow
import io.kotest.core.spec.style.StringSpec
import io.kotest.matchers.shouldBe
import io.mockk.every
import io.mockk.mockk
import io.mockk.verify
import org.springframework.http.HttpStatus
import org.springframework.web.server.ResponseStatusException
import java.sql.Timestamp
import java.time.Instant

class SongNoteServiceTest: StringSpec({
    // Mocks
    val mockSongNoteRepository = mockk<SongNoteRepository>()
    val mockUserRepository = mockk<UserRepository>()
    val mockSongRepository = mockk<SongRepository>()
    val service = SongNoteService(mockSongNoteRepository, mockUserRepository, mockSongRepository)

    val band1 = Band("Jošafat",  "", "[]", emptyList(), emptyList(), 1)
    val band2 = Band("Agapebend", "", "[]", emptyList(), emptyList(), 2)

    val sb1 = SongBook("Jošafat", emptyList(), band1, 1)
    val sb2 = SongBook("Agapebend", emptyList(), band2, 2)

    val timeStampNow = Timestamp.from(Instant.now())

    val user = User("mockLoginSecret", "mockk@test.cz", "Mock", listOf(), listOf(), 1)
    val song1 = Song("Kéž se všichni svatí", "Text 1", SongKey.E.name, 120, SongBeat.FOUR_FOURTHS.name, 0, timeStampNow, 1, sb1, 1)
    val song2 = Song("Služme Pánu s bázní", "Text 2", SongKey.D.name, 130, SongBeat.FOUR_FOURTHS.name, -2, timeStampNow, null, sb2, 2)
    val note = SongNote(song2, user, "Poznámky 1", 1, timeStampNow, 1)
    val noteDto = SongNoteReadDTO(note.id, note.notes, note.capo, note.lastEdit)

    val role1 = Role(RoleLevel.MUSICIAN, 1)
    val role2 = Role(RoleLevel.SINGER, 2)
    val bandMember1 = BandMember(band1, user, role1)
    val bandMember2 = BandMember(band2, user, role2)
    val userReal = user.copy(bands = listOf(bandMember1, bandMember2))
    val userDto = UserReadDTO(user.id, user.email, user.name, emptyList())

    val updateDto = SongNoteUpdateDTO("Poznámky 1", 1)

    "Believer_putSongNote" {
        val e = shouldThrow<ResponseStatusException> {
            service.putSongNote(sb1.id, song1.id, updateDto, null)
        }
        e.status shouldBe HttpStatus.UNAUTHORIZED
    }

    "Singer_putSongNote" {
        every { mockUserRepository.getByEmail(userDto.email) } returns userReal
        every { mockSongRepository.getById(song2.id) } returns song2
        every { mockSongNoteRepository.getBySongAndUser(song2, userReal) } returns null

        val e = shouldThrow<ResponseStatusException> {
            service.putSongNote(sb2.id, song2.id, updateDto, userDto)
        }
        e.status shouldBe HttpStatus.FORBIDDEN

        verify { mockUserRepository.getByEmail(userDto.email) }
        verify { mockSongRepository.getById(song2.id) }
        verify { mockSongNoteRepository.getBySongAndUser(song2, userReal) }
    }

    val partialDto = SongNoteUpdateDTO("Poznámka", null)

    "Musician_putSongNote_invalid" {
        every { mockUserRepository.getByEmail(userDto.email) } returns userReal
        every { mockSongRepository.getById(song1.id) } returns song1
        every { mockSongNoteRepository.getBySongAndUser(song1, userReal) } returns null

        val e = shouldThrow<ResponseStatusException> {
            service.putSongNote(sb1.id, song1.id, partialDto, userDto)
        }
        e.status shouldBe HttpStatus.BAD_REQUEST

        verify { mockUserRepository.getByEmail(userDto.email) }
        verify { mockSongRepository.getById(song1.id) }
        every { mockSongNoteRepository.getBySongAndUser(song1, userReal) }
    }

    "Musician_putSongNote_new" {
        every { mockUserRepository.getByEmail(userDto.email) } returns userReal
        every { mockSongRepository.getById(song1.id) } returns song1
        every { mockSongNoteRepository.getBySongAndUser(song1, userReal) } returns null
        every { mockSongNoteRepository.saveAndFlush(any()) } returns note

        service.putSongNote(sb1.id, song1.id, updateDto, userDto) shouldBe noteDto

        verify { mockUserRepository.getByEmail(userDto.email) }
        verify { mockSongRepository.getById(song1.id) }
        verify { mockSongNoteRepository.getBySongAndUser(song1, userReal) }
        verify { mockSongNoteRepository.saveAndFlush(any()) }
    }

    val note1 = note.copy(song = song1)
    val note1Updated = note1.copy(notes = partialDto.notes ?: "")
    val updatedNoteDto = noteDto.copy(notes = note1Updated.notes)

    "Musician_putSongNote_update" {
        every { mockUserRepository.getByEmail(userDto.email) } returns userReal
        every { mockSongRepository.getById(song1.id) } returns song1
        every { mockSongNoteRepository.getBySongAndUser(song1, userReal) } returns note1
        every { mockSongNoteRepository.saveAndFlush(any()) } returns note1Updated

        service.putSongNote(sb1.id, song1.id, updateDto, userDto) shouldBe updatedNoteDto

        verify { mockUserRepository.getByEmail(userDto.email) }
        verify { mockSongRepository.getById(song1.id) }
        verify { mockSongNoteRepository.getBySongAndUser(song1, userReal) }
        verify { mockSongNoteRepository.saveAndFlush(any()) }
    }
})