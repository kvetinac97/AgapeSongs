package cz.fit.cvut.wrzecond.agapesongs.service

import cz.fit.cvut.wrzecond.agapesongs.dto.*
import cz.fit.cvut.wrzecond.agapesongs.entity.*
import cz.fit.cvut.wrzecond.agapesongs.repository.BandMemberRepository
import cz.fit.cvut.wrzecond.agapesongs.repository.BandRepository
import cz.fit.cvut.wrzecond.agapesongs.repository.RoleRepository
import cz.fit.cvut.wrzecond.agapesongs.repository.UserRepository
import io.kotest.assertions.throwables.shouldThrow
import io.kotest.core.spec.style.StringSpec
import io.kotest.matchers.shouldBe
import io.mockk.every
import io.mockk.mockk
import io.mockk.verify
import org.springframework.http.HttpStatus
import org.springframework.web.server.ResponseStatusException

class BandMemberServiceTest: StringSpec ({
    // Mocks
    val mockUserRepository = mockk<UserRepository>()
    val mockUserService = mockk<UserService>()
    every { mockUserService.repository } returns mockUserRepository

    val mockBandMemberRepository = mockk<BandMemberRepository>()
    val mockRoleRepository = mockk<RoleRepository>()
    val mockBandRepository = mockk<BandRepository>()
    val service = BandMemberService(mockBandMemberRepository, mockRoleRepository, mockBandRepository, mockUserService)

    // Init general data
    val band1 = Band("Jóšafat", "", "[]", emptyList(), emptyList(), 1)
    val band2 = Band("Agapebend", "", "[]", emptyList(), emptyList(), 2)

    "Believer_createMember" {
        val createDto = BandMemberCreateDTO("mockk@test.cz", "Mock", 1)

        every { mockBandRepository.getById(band1.id) } returns band1

        val e = shouldThrow<ResponseStatusException> {
            service.createMember(band1.id, createDto, null)
        }
        e.status shouldBe HttpStatus.UNAUTHORIZED

        verify { mockBandRepository.getById(band1.id) }
    }

    // Prepare BandMember data
    val user = User("anotherSecret", "second@test.cz", "Second", emptyList(), emptyList(), 2)
    val role = Role(RoleLevel.SINGER, 2)
    val bandMember = BandMember(band2, user, role, 1)

    "Believer_changeMember" {
        val updateDto = BandMemberUpdateDTO(1)

        every { mockBandMemberRepository.getById(bandMember.id) } returns bandMember

        val e = shouldThrow<ResponseStatusException> {
            service.changeMember(band2.id, bandMember.id, updateDto, null)
        }
        e.status shouldBe HttpStatus.UNAUTHORIZED

        verify { mockBandMemberRepository.getById(bandMember.id) }
    }

    "Believer_deleteMember" {
        every { mockBandMemberRepository.getById(bandMember.id) } returns bandMember

        val e = shouldThrow<ResponseStatusException> {
            service.deleteMember(band2.id, bandMember.id, null)
        }
        e.status shouldBe HttpStatus.UNAUTHORIZED

        verify { mockBandMemberRepository.getById(bandMember.id) }
    }

    val memberDto = UserReadDTO(1, "mockk@test.cz", "Mock", emptyList())
    val member = User("mockLoginSecret", memberDto.email, memberDto.name, emptyList(), emptyList(), 1)
    val memberSelf = BandMember(band2, member, Role(RoleLevel.MUSICIAN, 1), 2)
    val memberReal = member.copy(bands = listOf(
        BandMember(band1, member, Role(RoleLevel.LEADER, 1), 1),
        memberSelf
    ))

    "Member_createMember" {
        val createDto = BandMemberCreateDTO("create@test.cz", "Create", 1)

        every { mockBandRepository.getById(band2.id) } returns band2
        every { mockUserRepository.getByEmail(memberDto.email) } returns memberReal

        val e = shouldThrow<ResponseStatusException> {
            service.createMember(band2.id, createDto, memberDto)
        }
        e.status shouldBe HttpStatus.FORBIDDEN

        verify { mockBandRepository.getById(band2.id) }
        verify { mockUserRepository.getByEmail(memberDto.email) }
    }

    "Member_changeMember" {
        val updateDto = BandMemberUpdateDTO(1)

        every { mockBandMemberRepository.getById(bandMember.id) } returns bandMember
        every { mockUserRepository.getByEmail(memberDto.email) } returns memberReal

        val e = shouldThrow<ResponseStatusException> {
            service.changeMember(band2.id, bandMember.id, updateDto, memberDto)
        }
        e.status shouldBe HttpStatus.FORBIDDEN

        verify { mockBandMemberRepository.getById(bandMember.id) }
        verify { mockUserRepository.getByEmail(memberDto.email) }
    }

    "Member_deleteMember" {
        every { mockBandMemberRepository.getById(bandMember.id) } returns bandMember
        every { mockUserRepository.getByEmail(memberDto.email) } returns memberReal

        val e = shouldThrow<ResponseStatusException> {
            service.deleteMember(band2.id, bandMember.id, memberDto)
        }
        e.status shouldBe HttpStatus.FORBIDDEN

        verify { mockBandMemberRepository.getById(bandMember.id) }
        verify { mockUserRepository.getByEmail(memberDto.email) }
    }

    "Member_deleteSelf" {
        every { mockBandMemberRepository.getById(memberSelf.id) } returns memberSelf
        every { mockBandMemberRepository.delete(memberSelf) } returns Unit
        every { mockUserRepository.getByEmail(memberDto.email) } returns memberReal

        service.deleteMember(band2.id, memberSelf.id, memberDto)

        verify { mockBandMemberRepository.getById(memberSelf.id) }
        verify { mockBandMemberRepository.delete(memberSelf) }
        verify { mockUserRepository.getByEmail(memberDto.email) }
    }

    "Leader_createMember" {
        val createDto = BandMemberCreateDTO("create@test.cz", "Create", 1)
        val createUser = User("anotherLoginSecret", createDto.email, createDto.name, emptyList(), emptyList(), 2)
        val createRole = Role(RoleLevel.MUSICIAN, createDto.roleId)
        val expectedBm = BandMember(band1, createUser, createRole)
        val expectedDto = BandMemberReadDTO(3, BandReadDTO(band1.id, band1.name, "", emptyList()),
            UserReadDTO(createUser.id, createUser.email, createUser.name, emptyList()),
            RoleReadDTO(createRole.id, createRole.level.name)
        )

        every { mockBandRepository.getById(band1.id) } returns band1
        every { mockUserRepository.getByEmail(memberDto.email) } returns memberReal
        every { mockUserService.getOrCreate(createDto.email, createDto.name) } returns createUser
        every { mockRoleRepository.getById(createDto.roleId) } returns createRole
        every { mockBandMemberRepository.saveAndFlush(expectedBm) } returns expectedBm.copy(id = expectedDto.id)

        service.createMember(band1.id, createDto, memberDto) shouldBe expectedDto

        verify { mockBandRepository.getById(band1.id) }
        verify { mockUserRepository.getByEmail(memberDto.email) }
        verify { mockUserService.getOrCreate(createDto.email, createDto.name) }
        verify { mockRoleRepository.getById(createDto.roleId) }
        verify { mockBandMemberRepository.saveAndFlush(expectedBm) }
    }

    "Leader_changeMember" {
        val updateDto = BandMemberUpdateDTO(2)
        val updateRole = Role(RoleLevel.SINGER, updateDto.roleId)

        val originalBm = BandMember(band1, user, Role(RoleLevel.MUSICIAN, 1), 4)
        val expectedBm = BandMember(band1, user, updateRole, originalBm.id)
        val expectedDto = BandMemberReadDTO(originalBm.id, BandReadDTO(band1.id, band1.name, "", emptyList()),
            UserReadDTO(user.id, user.email, user.name, emptyList()),
            RoleReadDTO(updateRole.id, updateRole.level.name)
        )

        every { mockUserRepository.getByEmail(memberDto.email) } returns memberReal
        every { mockBandMemberRepository.getById(originalBm.id) } returns originalBm
        every { mockRoleRepository.getById(updateDto.roleId) } returns updateRole
        every { mockBandMemberRepository.saveAndFlush(expectedBm) } returns expectedBm.copy(id = expectedDto.id)

        service.changeMember(band1.id, originalBm.id, updateDto, memberDto) shouldBe expectedDto

        verify { mockUserRepository.getByEmail(memberDto.email) }
        verify { mockBandMemberRepository.getById(originalBm.id) }
        verify { mockRoleRepository.getById(updateDto.roleId) }
        verify { mockBandMemberRepository.saveAndFlush(expectedBm) }
    }

    "Leader_deleteMember" {
        val originalBm = BandMember(band1, user, Role(RoleLevel.MUSICIAN, 1), 4)

        every { mockUserRepository.getByEmail(memberDto.email) } returns memberReal
        every { mockBandMemberRepository.getById(originalBm.id) } returns originalBm
        every { mockBandMemberRepository.delete(originalBm) } returns Unit

        service.deleteMember(band1.id, originalBm.id, memberDto) shouldBe Unit

        verify { mockUserRepository.getByEmail(memberDto.email) }
        verify { mockBandMemberRepository.getById(originalBm.id) }
        verify { mockBandMemberRepository.delete(originalBm) }
    }
})