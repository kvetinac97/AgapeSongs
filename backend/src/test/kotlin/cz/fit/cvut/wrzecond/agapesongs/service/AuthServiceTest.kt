package cz.fit.cvut.wrzecond.agapesongs.service

import cz.fit.cvut.wrzecond.agapesongs.dto.AuthDTO
import cz.fit.cvut.wrzecond.agapesongs.dto.UserLoginDTO
import cz.fit.cvut.wrzecond.agapesongs.entity.User
import cz.fit.cvut.wrzecond.agapesongs.repository.*
import io.kotest.assertions.throwables.shouldThrow
import io.kotest.core.spec.style.StringSpec
import io.kotest.matchers.shouldBe
import io.mockk.every
import io.mockk.mockk
import io.mockk.verify
import org.springframework.core.env.Environment
import org.springframework.core.io.ClassPathResource
import org.springframework.http.HttpStatus
import org.springframework.web.server.ResponseStatusException

class AuthServiceTest: StringSpec({
    // Mocks
    val mockBandRepository = mockk<BandRepository>()
    val mockBandMemberRepository = mockk<BandMemberRepository>()
    val mockRoleRepository = mockk<RoleRepository>()
    val mockSongBookRepository = mockk<SongBookRepository>()
    val mockSongRepository = mockk<SongRepository>()
    val mockUserRepository = mockk<UserRepository>()
    val mockNetworkService = mockk<NetworkService>()
    val mockEnvironment = mockk<Environment>()
    every { mockEnvironment.getProperty("auth.keyPath", "") } returns ClassPathResource("mockkey.p8").file.absolutePath
    every { mockEnvironment.getProperty("auth.keyId", "") } returns ""
    every { mockEnvironment.getProperty("auth.teamId", "") } returns ""
    val service = AuthService(mockUserRepository, mockBandRepository, mockBandMemberRepository,
        mockRoleRepository, mockSongBookRepository, mockSongRepository,
        mockNetworkService, mockEnvironment)

    // Initial data
    val authDto = AuthDTO("bad-code-mock-1234")

    "authenticate" {
        val user = User("mockLoginSecret", "mockk@test.cz", "Test User", emptyList(), emptyList(), 1)
        val userDto = UserLoginDTO(user.id, user.loginSecret, user.email, user.name)

        every { mockUserRepository.getByEmail(user.email) } returns user
        every { mockNetworkService.appleAuthRequest(authDto.code, any()) } returns "{\"id_token\":\"any.eyJlbWFpbCI6ICJtb2Nra0B0ZXN0LmN6IiwgImVtYWlsX3ZlcmlmaWVkIjogdHJ1ZX0=\"}"

        service.authenticate(authDto) shouldBe userDto

        verify { mockUserRepository.getByEmail(user.email) }
        verify { mockNetworkService.appleAuthRequest(authDto.code, any()) }
    }

    "authenticate_bad" {
        every { mockNetworkService.appleAuthRequest(authDto.code, any()) } returns "{}"

        val e = shouldThrow<ResponseStatusException> {
            service.authenticate(authDto)
        }
        e.status shouldBe HttpStatus.BAD_REQUEST

        verify { mockNetworkService.appleAuthRequest(authDto.code, any()) }
    }
})