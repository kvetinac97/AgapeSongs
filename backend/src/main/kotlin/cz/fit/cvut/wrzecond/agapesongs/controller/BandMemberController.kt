package cz.fit.cvut.wrzecond.agapesongs.controller

import cz.fit.cvut.wrzecond.agapesongs.dto.*
import cz.fit.cvut.wrzecond.agapesongs.service.BandMemberService
import cz.fit.cvut.wrzecond.agapesongs.service.UserService
import org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.DeleteMapping
import org.springframework.web.bind.annotation.PatchMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.ResponseStatus
import org.springframework.web.bind.annotation.RestController
import javax.servlet.http.HttpServletRequest

@RestController
@RequestMapping("/band/{id}/members")
class BandMemberController (val service: BandMemberService, userService: UserService) : IControllerAuth(userService) {

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    fun createMember(@PathVariable id: Int, @RequestBody dto: BandMemberCreateDTO, request: HttpServletRequest)
        = authenticate(request, VisibilitySettings.LOGGED) { user -> service.createMember(id, dto, user) }

    @PatchMapping("/{memberId}")
    @ResponseStatus(HttpStatus.OK)
    fun changeMember(@PathVariable id: Int, @PathVariable memberId: Int,
                     @RequestBody dto: BandMemberUpdateDTO, request: HttpServletRequest)
        = authenticate(request, VisibilitySettings.LOGGED) { user -> service.changeMember(id, memberId, dto, user) }

    @DeleteMapping("/{memberId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    fun deleteMember(@PathVariable id: Int, @PathVariable memberId: Int, request: HttpServletRequest)
        = authenticate(request, VisibilitySettings.LOGGED) { user -> service.deleteMember(id, memberId, user) }

}
