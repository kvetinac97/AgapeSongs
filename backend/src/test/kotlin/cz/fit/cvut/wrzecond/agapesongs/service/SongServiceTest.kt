package cz.fit.cvut.wrzecond.agapesongs.service

import cz.fit.cvut.wrzecond.agapesongs.dto.*
import cz.fit.cvut.wrzecond.agapesongs.entity.*
import cz.fit.cvut.wrzecond.agapesongs.repository.SongBookRepository
import cz.fit.cvut.wrzecond.agapesongs.repository.SongRepository
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

class SongServiceTest: StringSpec ({
    // Mocks
    val mockSongRepository = mockk<SongRepository>()
    val mockSongBookRepository = mockk<SongBookRepository>()
    val mockUserRepository = mockk<UserRepository>()
    val service = SongService(mockSongRepository, mockSongBookRepository, mockUserRepository)

    val band1 = Band("Jošafat",  "", "[]", emptyList(), emptyList(), 1)
    val songBook = SongBook("Jošafat", emptyList(), band1, 1)
    val createDto = SongCreateDTO("Kéž se všichni svatí", "Text 1", SongKey.E, 120, SongBeat.FOUR_FOURTHS, 2, songBook.id, 1)

    "Believer_create" {
        every { mockSongBookRepository.getById(songBook.id) } returns songBook

        val e = shouldThrow<ResponseStatusException> {
            service.create(createDto, null)
        }
        e.status shouldBe HttpStatus.UNAUTHORIZED

        verify { mockSongBookRepository.getById(songBook.id) }
    }

    val band2 = Band("Agapebend", "", "[]", emptyList(), emptyList(), 2)
    val songBook2 = SongBook("Agapebend", emptyList(), band2, 2)

    val timeStampNow = Timestamp.from(Instant.now())
    val song = Song("Kéž se všichni svatí", "[]", SongKey.E.name, 120, SongBeat.FOUR_FOURTHS.name, 1, timeStampNow, 1, songBook, 1)
    val updateDto = SongUpdateDTO("Hava nagila", null, SongKey.B_FLAT, 90, null,  null, null, null)

    "Believer_update" {
        every { mockSongRepository.getById(song.id) } returns song

        val e = shouldThrow<ResponseStatusException> {
            service.update(song.id, updateDto, null)
        }
        e.status shouldBe HttpStatus.UNAUTHORIZED

        verify { mockSongRepository.getById(song.id) }
    }

    "Believer_delete" {
        every { mockSongRepository.getById(song.id) } returns song

        val e = shouldThrow<ResponseStatusException> {
            service.delete(song.id, null)
        }
        e.status shouldBe HttpStatus.UNAUTHORIZED

        verify { mockSongRepository.getById(song.id) }
    }

    val user = User("mockLoginSecret", "mockk@test.cz", "Mock", listOf(), listOf(), 1)
    val role1 = Role(RoleLevel.MUSICIAN, 1)
    val role2 = Role(RoleLevel.SINGER, 2)
    val bandMember1 = BandMember(band1, user, role1)
    val bandMember2 = BandMember(band2, user, role2)
    val userReal = user.copy(bands = listOf(bandMember1, bandMember2))
    val userDto = UserReadDTO(user.id, user.email, user.name, emptyList())

    val timeCreate = Timestamp.from(Instant.now())
    val songCreated = song.copy(lastEdit = timeCreate)
    val songDto = SongReadDTO(song.id, SongBookReadDTO(song.songBook.id, song.songBook.name,
        BandReadDTO(band1.id, band1.name, band1.secret, emptyList()), emptyList()), song.name,
        listOf(), SongKey.valueOf(song.key), song.bpm, SongBeat.valueOf(song.beat), song.capo, timeCreate, song.displayId, null)

    "Musician_create" {
        every { mockSongBookRepository.getById(songBook.id) } returns songBook
        every { mockUserRepository.getByEmail(user.email) } returns userReal
        every { mockSongRepository.saveAndFlush(any()) } returns songCreated

        service.create(createDto, userDto) shouldBe songDto

        verify { mockSongBookRepository.getById(songBook.id) }
        verify { mockUserRepository.getByEmail(user.email) }
        verify { mockSongRepository.saveAndFlush(any()) }
    }

    val createDto2 = createDto.copy(songBookId = songBook2.id)

    "Singer_create" {
        every { mockSongBookRepository.getById(songBook2.id) } returns songBook2
        every { mockUserRepository.getByEmail(user.email) } returns userReal

        val e = shouldThrow<ResponseStatusException> {
            service.create(createDto2, userDto)
        }
        e.status shouldBe HttpStatus.FORBIDDEN

        verify { mockSongBookRepository.getById(songBook2.id) }
        verify { mockUserRepository.getByEmail(user.email) }
    }

    val songUpdated = song.copy(name = "Hava nagila", key = SongKey.B_FLAT.name, bpm = 90, displayId = null)
    val songUpdatedDto = songDto.copy(name = songUpdated.name,
        key = SongKey.B_FLAT, bpm = songUpdated.bpm, displayId = songUpdated.displayId)

    "Musician_update" {
        every { mockSongRepository.getById(song.id) } returns song
        every { mockUserRepository.getByEmail(user.email) } returns userReal
        every { mockSongRepository.saveAndFlush(any()) } returns songUpdated

        val result = service.update(song.id, updateDto, userDto)
        result.copy(lastEdit = songUpdatedDto.lastEdit) shouldBe songUpdatedDto

        verify { mockSongRepository.getById(song.id) }
        verify { mockUserRepository.getByEmail(user.email) }
        verify { mockSongRepository.saveAndFlush(any()) }
    }

    val updateDto2 = updateDto.copy(songBookId = songBook2.id)

    "Singer_update" {
        every { mockSongRepository.getById(song.id) } returns song
        every { mockSongBookRepository.getById(songBook2.id) } returns songBook2
        every { mockUserRepository.getByEmail(user.email) } returns userReal

        val e = shouldThrow<ResponseStatusException> {
            service.update(song.id, updateDto2, userDto)
        }
        e.status shouldBe HttpStatus.FORBIDDEN

        verify { mockSongRepository.getById(song.id) }
        verify { mockSongBookRepository.getById(songBook2.id) }
        verify { mockUserRepository.getByEmail(user.email) }
    }

    "Musician_delete" {
        every { mockSongRepository.getById(song.id) } returns song
        every { mockUserRepository.getByEmail(user.email) } returns userReal
        every { mockSongRepository.delete(song) } returns Unit

        service.delete(song.id, userDto) shouldBe Unit

        verify { mockSongRepository.getById(song.id) }
        verify { mockUserRepository.getByEmail(user.email) }
        verify { mockSongRepository.delete(song) }
    }

    val song2 = song.copy(songBook = songBook2)

    "Singer_delete" {
        every { mockSongRepository.getById(song2.id) } returns song2
        every { mockUserRepository.getByEmail(user.email) } returns userReal

        val e = shouldThrow<ResponseStatusException> {
            service.delete(song2.id, userDto)
        }
        e.status shouldBe HttpStatus.FORBIDDEN

        verify { mockSongRepository.getById(song2.id) }
        verify { mockUserRepository.getByEmail(user.email) }
    }
})