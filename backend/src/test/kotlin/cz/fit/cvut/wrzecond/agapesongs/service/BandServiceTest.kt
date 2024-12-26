package cz.fit.cvut.wrzecond.agapesongs.service

import cz.fit.cvut.wrzecond.agapesongs.dto.BandReadDTO
import cz.fit.cvut.wrzecond.agapesongs.dto.PlaylistDTO
import cz.fit.cvut.wrzecond.agapesongs.dto.SongBeat
import cz.fit.cvut.wrzecond.agapesongs.dto.UserReadDTO
import cz.fit.cvut.wrzecond.agapesongs.entity.*
import cz.fit.cvut.wrzecond.agapesongs.repository.*
import io.kotest.assertions.throwables.shouldThrow
import io.kotest.core.spec.style.StringSpec
import io.kotest.matchers.shouldBe
import io.mockk.every
import io.mockk.mockk
import io.mockk.verify
import org.springframework.data.domain.Sort
import org.springframework.http.HttpStatus
import org.springframework.web.server.ResponseStatusException
import java.sql.Timestamp
import java.time.Instant

class BandServiceTest: StringSpec({
    // Mocks
    val mockBandRepository = mockk<BandRepository>()
    val mockRoleRepository = mockk<RoleRepository>()
    val mockUserRepository = mockk<UserRepository>()
    val mockSongRepository = mockk<SongRepository>()
    val mockBandMemberRepository = mockk<BandMemberRepository>()
    val service = BandService(mockBandRepository, mockRoleRepository, mockSongRepository,
            mockUserRepository, mockBandMemberRepository)

    // Init general data
    val band1 = Band("Jóšafat", "", "[]", emptyList(), emptyList(), 1)
    val band2 = Band("Agapebend", "", "[2, 5, 9]", emptyList(), emptyList(), 2)
    val band3 = Band("Přístav Worship", "", "[]", emptyList(), emptyList(), 3)

    val bandDto1 = BandReadDTO(band1.id, band1.name, "", emptyList())
    val bandDto2 = BandReadDTO(band2.id, band2.name, "", emptyList())
    val playlistDto = PlaylistDTO(listOf(1, 2, 8))

    "Believer_findAll" {
        every { mockBandRepository.findAll(any<Sort>()) } returns listOf(band1, band2, band3)

        service.findAll(null) shouldBe emptyList()

        verify { mockBandRepository.findAll(any<Sort>()) }
    }

    "Believer_getById" {
        every { mockBandRepository.getById(band1.id) } returns band1

        val e = shouldThrow<ResponseStatusException> {
            service.getByID(band1.id, null)
        }
        e.status shouldBe HttpStatus.UNAUTHORIZED

        verify { mockBandRepository.getById(band1.id) }
    }

    "Believer_getPlaylist" {
        every { mockBandRepository.getById(band1.id) } returns band1

        val e = shouldThrow<ResponseStatusException> {
            service.getPlaylist(band1.id, null)
        }
        e.status shouldBe HttpStatus.UNAUTHORIZED

        verify { mockBandRepository.getById(band1.id) }
    }

    "Believer_putPlaylist" {
        every { mockBandRepository.getById(band1.id) } returns band1

        val e = shouldThrow<ResponseStatusException> {
            service.putPlaylist(band1.id, playlistDto, null)
        }
        e.status shouldBe HttpStatus.UNAUTHORIZED

        verify { mockBandRepository.getById(band1.id) }
    }

    // Init member data
    val memberDto = UserReadDTO(1, "mockk@test.cz", "Mock", emptyList())
    val member = User("mockLoginSecret", memberDto.email, memberDto.name, emptyList(), emptyList(), 1)
    val memberReal = member.copy(bands = listOf(
        BandMember(band1, member, Role(RoleLevel.LEADER, 1), 1),
        BandMember(band2, member, Role(RoleLevel.MUSICIAN, 1), 2)
    ))

    "Member_findAll" {
        every { mockBandRepository.findAll(any<Sort>()) } returns listOf(band1, band2, band3)
        every { mockUserRepository.getByEmail(memberDto.email) } returns memberReal

        service.findAll(memberDto) shouldBe listOf(bandDto2, bandDto1)

        verify { mockBandRepository.findAll(any<Sort>()) }
        verify { mockUserRepository.getByEmail(memberDto.email) }
    }

    "Member_getById" {
        every { mockBandRepository.getById(band2.id) } returns band2
        every { mockUserRepository.getByEmail(memberDto.email) } returns memberReal

        service.getByID(band2.id, memberDto) shouldBe bandDto2

        verify { mockBandRepository.getById(band2.id) }
        verify { mockUserRepository.getByEmail(memberDto.email) }
    }

    "Member_getById_fail" {
        every { mockBandRepository.getById(band3.id) } returns band3
        every { mockUserRepository.getByEmail(memberDto.email) } returns memberReal

        val e = shouldThrow<ResponseStatusException> {
            service.getByID(band3.id, memberDto)
        }
        e.status shouldBe HttpStatus.FORBIDDEN

        verify { mockBandRepository.getById(band3.id) }
        verify { mockUserRepository.getByEmail(memberDto.email) }
    }

    val dummySong = Song("Píseň", "Text", "C", 90, SongBeat.FOUR_FOURTHS.name, 0, Timestamp.from(Instant.now()),
        null, SongBook("Zpěvník", emptyList(), band1, 1), 2)

    "Member_getPlaylist" {
        every { mockBandRepository.getById(band2.id) } returns band2
        every { mockUserRepository.getByEmail(memberDto.email) } returns memberReal
        every { mockSongRepository.findByIds(listOf(2, 5, 9)) } returns listOf(dummySong)

        val playlist = service.getPlaylist(band2.id, memberDto)
        playlist shouldBe PlaylistDTO(listOf(2))

        verify { mockBandRepository.getById(band2.id) }
        verify { mockUserRepository.getByEmail(memberDto.email) }
        verify { mockSongRepository.findByIds(listOf(2, 5, 9)) }
    }
    "Member_putPlaylist" {
        every { mockBandRepository.getById(band2.id) } returns band2
        every { mockUserRepository.getByEmail(memberDto.email) } returns memberReal

        val e = shouldThrow<ResponseStatusException> {
            service.putPlaylist(band2.id, playlistDto, memberDto)
        }
        e.status shouldBe HttpStatus.FORBIDDEN

        verify { mockBandRepository.getById(band2.id) }
        verify { mockUserRepository.getByEmail(memberDto.email) }
    }

    "Leader_putPlaylist" {
        every { mockBandRepository.getById(band1.id) } returns band1
        every { mockUserRepository.getByEmail(memberDto.email) } returns memberReal
        every { mockSongRepository.findByIds(listOf(1, 2, 8)) } returns listOf(
            dummySong.copy(id = 1), dummySong.copy(id = 8)
        )
        every { mockBandRepository.saveAndFlush(band1.copy(playlist = "[1,8]")) } returns band1

        val playlist = service.putPlaylist(band1.id, playlistDto, memberDto)
        playlist shouldBe PlaylistDTO(listOf(1, 8))

        verify { mockBandRepository.getById(band1.id) }
        verify { mockUserRepository.getByEmail(memberDto.email) }
        verify { mockSongRepository.findByIds(listOf(1, 2, 8)) }
        verify { mockBandRepository.saveAndFlush(band1.copy(playlist = "[1,8]")) }
    }
})