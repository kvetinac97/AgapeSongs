package cz.fit.cvut.wrzecond.agapesongs.controller

import cz.fit.cvut.wrzecond.agapesongs.dto.AuthDTO
import cz.fit.cvut.wrzecond.agapesongs.service.AuthService
import cz.fit.cvut.wrzecond.agapesongs.service.UserService
import org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.*
import javax.servlet.http.HttpServletRequest

@RestController
@RequestMapping("/user")
class UserController (private val authService: AuthService, private val userService: UserService)
    : IControllerAuth(userService) {

    @PostMapping("/login")
    fun authenticate (@RequestBody dto: AuthDTO) = authService.authenticate(dto)

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    fun delete (@PathVariable id: Int, request: HttpServletRequest)
        = authenticate(request, VisibilitySettings.LOGGED) { user -> userService.delete(id, user) }

}
