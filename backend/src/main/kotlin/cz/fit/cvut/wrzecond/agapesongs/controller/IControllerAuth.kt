package cz.fit.cvut.wrzecond.agapesongs.controller

import cz.fit.cvut.wrzecond.agapesongs.dto.UserReadDTO
import cz.fit.cvut.wrzecond.agapesongs.service.UserService
import org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.CrossOrigin
import org.springframework.web.server.ResponseStatusException
import javax.servlet.http.HttpServletRequest
import kotlin.reflect.full.findAnnotation

@CrossOrigin(origins = ["https://kvetinac97.cz", "https://www.kvetinac97.cz"])
abstract class IControllerAuth (private val userService: UserService) {

    // === AUTHENTICATION ===
    protected fun <A> authenticate (request: HttpServletRequest, function: (Visibility) -> VisibilitySettings, action: (UserReadDTO?) -> A) : A {
        val annotation = this::class.findAnnotation<Visibility>()
        return authenticate(request, function(annotation!!), action)
    }
    protected fun <A> authenticate (request: HttpServletRequest, settings: VisibilitySettings, action: (UserReadDTO?) -> A) : A {
        // Try to load user
        val loginSecret = request.getHeader("LOGIN_SECRET") ?: ""
        val dto = userService.getByLoginSecret(loginSecret)

        when (settings) {
            VisibilitySettings.ALL    -> {}
            VisibilitySettings.LOGGED -> if (dto == null) throw ResponseStatusException(HttpStatus.UNAUTHORIZED)
            VisibilitySettings.NONE   -> throw ResponseStatusException(HttpStatus.METHOD_NOT_ALLOWED)
        }

        // Perform requested action
        return action(dto)
    }
    // === AUTHENTICATION ===

}

// Helper auth annotation class
annotation class Visibility (
    val findAll: VisibilitySettings = VisibilitySettings.LOGGED,
    val getByID: VisibilitySettings = VisibilitySettings.LOGGED,
    val create : VisibilitySettings = VisibilitySettings.LOGGED,
    val delete : VisibilitySettings = VisibilitySettings.LOGGED,
    val update : VisibilitySettings = VisibilitySettings.LOGGED
)
enum class VisibilitySettings { NONE, LOGGED, ALL }
