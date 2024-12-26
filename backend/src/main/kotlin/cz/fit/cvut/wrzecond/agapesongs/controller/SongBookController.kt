package cz.fit.cvut.wrzecond.agapesongs.controller

import cz.fit.cvut.wrzecond.agapesongs.dto.*
import cz.fit.cvut.wrzecond.agapesongs.entity.SongBook
import cz.fit.cvut.wrzecond.agapesongs.service.SongBookService
import cz.fit.cvut.wrzecond.agapesongs.service.UserService
import org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import org.springframework.web.server.ResponseStatusException
import java.text.SimpleDateFormat
import java.util.*
import javax.servlet.http.HttpServletRequest

@RestController
@RequestMapping("/songbook")
@Visibility(
    getByID = VisibilitySettings.NONE
)
class SongBookController (override val service: SongBookService, userService: UserService)
    : IControllerImpl<SongBook, SongBookReadDTO, SongBookCreateDTO, SongBookUpdateDTO>(service, userService) {

    @GetMapping
    override fun all(request: HttpServletRequest) = authenticate(request, { it.findAll }) { user ->
        val header = request.getHeader("If-Modified-Since") ?: ""
        val lastModified = try { sdf.parse(header).time } catch (exc: Exception) { 0 }

        // Support for Conditional GET
        val songBooks = service.findAll(user)
        if (lastModified != 0L && songBooks.maxOf { it.songs.maxOf { song -> song.lastEdit.time } } < lastModified)
            throw ResponseStatusException(HttpStatus.NOT_MODIFIED)
        songBooks
    }

}
