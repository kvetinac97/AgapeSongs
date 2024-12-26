package cz.fit.cvut.wrzecond.agapesongs.service

import cz.fit.cvut.wrzecond.agapesongs.dto.*
import cz.fit.cvut.wrzecond.agapesongs.entity.*
import cz.fit.cvut.wrzecond.agapesongs.repository.BandRepository
import cz.fit.cvut.wrzecond.agapesongs.repository.SongBookRepository
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

class SongBookServiceTest: StringSpec ({
    // Mocks
    val mockSongBookRepository = mockk<SongBookRepository>()
    val mockUserRepository = mockk<UserRepository>()
    val mockSongNoteRepository = mockk<SongNoteRepository>()
    val mockBandRepository = mockk<BandRepository>()
    val mockSongService = mockk<SongService>()
    val service = SongBookService(mockSongBookRepository, mockSongService, mockUserRepository,
        mockSongNoteRepository, mockBandRepository)

    "Believer_findAll" {
        val e = shouldThrow<ResponseStatusException> {
            service.findAll(null)
        }
        e.status shouldBe HttpStatus.UNAUTHORIZED
    }

    val band1 = Band("Jošafat", "", "[]", emptyList(), emptyList(), 1)
    val songBook = SongBook("Jošafat", emptyList(), band1, 1)
    val createDto = SongBookCreateDTO(songBook.name, band1.id)

    "Believer_create" {
        every { mockBandRepository.getById(band1.id) } returns band1

        val e = shouldThrow<ResponseStatusException> {
            service.create(createDto, null)
        }
        e.status shouldBe HttpStatus.UNAUTHORIZED

        verify { mockBandRepository.getById(band1.id) }
    }

    val songBook2 = songBook.copy(name = "Zpěvník")
    val updateDto = SongBookUpdateDTO(songBook2.name, null)

    "Believer_update" {
        every { mockSongBookRepository.getById(songBook.id) } returns songBook

        val e = shouldThrow<ResponseStatusException> {
            service.update(songBook.id, updateDto, null)
        }
        e.status shouldBe HttpStatus.UNAUTHORIZED

        verify { mockSongBookRepository.getById(songBook.id) }
    }

    "Believer_delete" {
        every { mockSongBookRepository.getById(songBook.id) } returns songBook

        val e = shouldThrow<ResponseStatusException> {
            service.delete(songBook.id, null)
        }
        e.status shouldBe HttpStatus.UNAUTHORIZED

        verify { mockSongBookRepository.getById(songBook.id) }
    }

    // User is musician in band 1 and singer in band 2
    val band2 = Band("Agapebend", "", "[]", emptyList(), emptyList(), 2)

    val sb1 = SongBook("Jošafat", emptyList(), band1, 1)
    val sb2 = SongBook("Agapebend", emptyList(), band2, 2)

    val timeStampNow = Timestamp.from(Instant.now())

    val user = User("mockLoginSecret", "mockk@test.cz", "Mock", listOf(), listOf(), 1)
    val song1 = Song("Kéž se všichni svatí", "Text 1", SongKey.E.name, 120, SongBeat.FOUR_FOURTHS.name, 0, timeStampNow, 1, sb1, 1)
    val song2 = Song("Hava nagila", "Text 2", SongKey.B_FLAT.name, 90, SongBeat.FOUR_FOURTHS.name, 0, timeStampNow, null, sb1, 2)
    val song3 = Song("Služme Pánu s bázní", "Text 3", SongKey.D.name, 130, SongBeat.FOUR_FOURTHS.name, 1, timeStampNow, 1, sb2, 3)
    val note = SongNote(song2, user, "Poznámky 1", 1, timeStampNow, 1)
    val noteDto = SongNoteReadDTO(note.id, note.notes, note.capo, note.lastEdit)

    val realSb1 = sb1.copy(songs = listOf(song1, song2))
    val realSb2 = sb2.copy(songs = listOf(song3))
    val rawSbDto = SongBookReadDTO(sb1.id, sb1.name, BandReadDTO(band1.id, band1.name, band1.secret, emptyList()), emptyList())

    val songBookDto1 = SongBookReadDTO(sb1.id, sb1.name, rawSbDto.band, listOf(
        SongReadDTO(song2.id, rawSbDto, song2.name, listOf(), SongKey.valueOf(song2.key), song2.bpm, SongBeat.valueOf(song2.beat), song2.capo, song2.lastEdit, song2.displayId, noteDto),
        SongReadDTO(song1.id, rawSbDto, song1.name, listOf(), SongKey.valueOf(song1.key), song1.bpm, SongBeat.valueOf(song1.beat), song1.capo, song1.lastEdit, song1.displayId, null)
    ))
    val songBookDto2 = SongBookReadDTO(sb2.id, sb2.name, BandReadDTO(band2.id, band2.name, band2.secret, emptyList()), listOf(
        SongReadDTO(song3.id, SongBookReadDTO(sb2.id, sb2.name, BandReadDTO(band2.id, band2.name, band2.secret, emptyList()), emptyList()),
            song3.name, listOf(), SongKey.valueOf(song3.key), song3.bpm, SongBeat.valueOf(song3.beat), song3.capo, song3.lastEdit, song3.displayId, null),
    ))

    val role1 = Role(RoleLevel.LEADER, 1)
    val role2 = Role(RoleLevel.SINGER, 2)
    val bandMember1 = BandMember(band1, user, role1)
    val bandMember2 = BandMember(band2, user, role2)
    val userReal = user.copy(bands = listOf(bandMember1, bandMember2))
    val userDto = UserReadDTO(user.id, user.email, user.name, emptyList())

    "User_findAll" {
        every { mockUserRepository.getByEmail(userDto.email) } returns userReal
        every { mockSongNoteRepository.findByUser(userReal) } returns listOf(note)
        every { mockSongBookRepository.findByBands(listOf(band1, band2)) } returns listOf(realSb1, realSb2)
        every { mockSongService.convertSongText(any()) } returns listOf()

        service.findAll(userDto) shouldBe listOf(songBookDto2, songBookDto1)

        verify { mockUserRepository.getByEmail(userDto.email) }
        verify { mockSongNoteRepository.findByUser(userReal) }
        verify { mockSongBookRepository.findByBands(listOf(band1, band2)) }
        verify { mockSongService.convertSongText(any()) }
    }

    val rawSongBook = songBook.copy(id = 0)
    val rawSongBookDto = songBookDto1.copy(songs = emptyList())

    "Leader_create" {
        every { mockUserRepository.getByEmail(userDto.email) } returns userReal
        every { mockBandRepository.getById(band1.id) } returns band1
        every { mockSongBookRepository.saveAndFlush(rawSongBook) } returns songBook

        service.create(createDto, userDto) shouldBe rawSongBookDto

        verify { mockUserRepository.getByEmail(userDto.email) }
        verify { mockBandRepository.getById(band1.id) }
        verify { mockSongBookRepository.saveAndFlush(rawSongBook) }
    }

    val createDto2 = createDto.copy(bandId = band2.id)

    "Singer_create" {
        every { mockUserRepository.getByEmail(userDto.email) } returns userReal
        every { mockBandRepository.getById(band2.id) } returns band2

        val e = shouldThrow<ResponseStatusException> {
            service.create(createDto2, userDto)
        }
        e.status shouldBe HttpStatus.FORBIDDEN

        verify { mockUserRepository.getByEmail(userDto.email) }
        verify { mockBandRepository.getById(band2.id) }
    }

    val rawSongBook2 = songBook.copy(name = "Zpěvník")
    "Musician_update" {
        every { mockUserRepository.getByEmail(userDto.email) } returns userReal
        every { mockSongBookRepository.getById(songBook.id) } returns songBook
        every { mockSongBookRepository.saveAndFlush(rawSongBook2) } returns rawSongBook2

        service.update(songBook.id, updateDto, userDto) shouldBe songBookDto1.copy(name = "Zpěvník", songs = emptyList())

        verify { mockUserRepository.getByEmail(userDto.email) }
        verify { mockSongBookRepository.getById(songBook.id) }
        verify { mockSongBookRepository.saveAndFlush(rawSongBook2) }
    }

    val evilSongBookDto = SongBookUpdateDTO(null, band2.id)
    "Singer_update" {
        every { mockUserRepository.getByEmail(userDto.email) } returns userReal
        every { mockSongBookRepository.getById(songBook.id) } returns songBook
        every { mockBandRepository.getById(band2.id) } returns band2

        val e = shouldThrow<ResponseStatusException> {
            service.update(songBook.id, evilSongBookDto, userDto)
        }
        e.status shouldBe HttpStatus.FORBIDDEN

        verify { mockUserRepository.getByEmail(userDto.email) }
        verify { mockSongBookRepository.getById(songBook.id) }
        verify { mockBandRepository.getById(band2.id) }
    }

    "Musician_delete" {
        every { mockUserRepository.getByEmail(userDto.email) } returns userReal
        every { mockSongBookRepository.getById(songBook.id) } returns songBook
        every { mockSongBookRepository.delete(songBook) } returns Unit

        service.delete(songBook.id, userDto) shouldBe Unit

        verify { mockUserRepository.getByEmail(userDto.email) }
        verify { mockSongBookRepository.getById(songBook.id) }
        verify { mockSongBookRepository.delete(songBook) }
    }

    "Singer_delete" {
        every { mockUserRepository.getByEmail(userDto.email) } returns userReal
        every { mockSongBookRepository.getById(sb2.id) } returns sb2

        val e = shouldThrow<ResponseStatusException> {
            service.delete(sb2.id, userDto)
        }
        e.status shouldBe HttpStatus.FORBIDDEN

        every { mockUserRepository.getByEmail(userDto.email) }
        verify { mockSongBookRepository.getById(sb2.id) }
    }
})