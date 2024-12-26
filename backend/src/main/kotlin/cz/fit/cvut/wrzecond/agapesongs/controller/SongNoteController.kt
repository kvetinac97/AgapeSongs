package cz.fit.cvut.wrzecond.agapesongs.controller

import cz.fit.cvut.wrzecond.agapesongs.dto.SongNoteUpdateDTO
import cz.fit.cvut.wrzecond.agapesongs.service.SongNoteService
import cz.fit.cvut.wrzecond.agapesongs.service.UserService
import org.springframework.web.bind.annotation.*
import javax.servlet.http.HttpServletRequest

@RestController
@RequestMapping("/songbook/{id}/songs/{songId}/notes")
@Visibility
class SongNoteController (val service: SongNoteService, userService: UserService) : IControllerAuth(userService) {

    @PutMapping
    fun putSongNote(@PathVariable id: Int, @PathVariable songId: Int,
                    @RequestBody dto: SongNoteUpdateDTO, request: HttpServletRequest)
        = authenticate(request, VisibilitySettings.LOGGED) { user -> service.putSongNote(id, songId, dto, user) }

}
