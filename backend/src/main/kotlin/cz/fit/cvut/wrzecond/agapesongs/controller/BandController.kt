package cz.fit.cvut.wrzecond.agapesongs.controller

import cz.fit.cvut.wrzecond.agapesongs.dto.*
import cz.fit.cvut.wrzecond.agapesongs.entity.Band
import cz.fit.cvut.wrzecond.agapesongs.entity.RoleLevel
import cz.fit.cvut.wrzecond.agapesongs.service.BandService
import cz.fit.cvut.wrzecond.agapesongs.service.UserService
import org.springframework.web.bind.annotation.*
import javax.servlet.http.HttpServletRequest
import javax.servlet.http.HttpServletResponse

@RestController
@RequestMapping("/band")
@Visibility(
    delete = VisibilitySettings.NONE
)
class BandController (override val service: BandService, userService: UserService)
    : IControllerImpl<Band, BandReadDTO, BandCreateDTO, BandUpdateDTO>(service, userService) {

    @GetMapping("/{id}/playlist")
    fun getPlaylist(@PathVariable id: Int, request: HttpServletRequest)
        = authenticate(request, VisibilitySettings.LOGGED) { user -> service.getPlaylist(id, user) }

    @PutMapping("/{id}/playlist")
    fun putPlaylist(@PathVariable id: Int, @RequestBody playlist: PlaylistDTO, request: HttpServletRequest)
        = authenticate(request, VisibilitySettings.LOGGED) { user -> service.putPlaylist(id, playlist, user) }

    @PostMapping("/join")
    fun join(@RequestBody band: BandJoinDTO, request: HttpServletRequest)
        = authenticate(request, VisibilitySettings.LOGGED) { user -> service.joinWithId(band, user) }

    override fun create(dto: BandCreateDTO, request: HttpServletRequest, response: HttpServletResponse)
        = authenticate(request, { it.create }) { user ->
        val exists = service.existsWithSecret(dto.secret)
        if (!exists || dto.secret == "") // if band does not exist, create new
            service.create(dto, user)
            // throw ResponseStatusException(HttpStatus.SERVICE_UNAVAILABLE)

        // add user to the band: created = LEADER, joined = SINGER
        service.join(dto, user, if (exists) RoleLevel.SINGER else RoleLevel.LEADER)
    }

}
