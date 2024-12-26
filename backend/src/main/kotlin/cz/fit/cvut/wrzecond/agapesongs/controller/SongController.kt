package cz.fit.cvut.wrzecond.agapesongs.controller

import cz.fit.cvut.wrzecond.agapesongs.dto.SongCreateDTO
import cz.fit.cvut.wrzecond.agapesongs.dto.SongReadDTO
import cz.fit.cvut.wrzecond.agapesongs.dto.SongUpdateDTO
import cz.fit.cvut.wrzecond.agapesongs.entity.Song
import cz.fit.cvut.wrzecond.agapesongs.service.SongService
import cz.fit.cvut.wrzecond.agapesongs.service.UserService
import org.springframework.http.HttpHeaders
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*
import org.springframework.web.server.ResponseStatusException
import java.text.Normalizer
import java.util.*
import javax.servlet.http.HttpServletRequest
import javax.servlet.http.HttpServletResponse

@RestController
@RequestMapping("/song")
@Visibility(
    findAll = VisibilitySettings.NONE,
    getByID = VisibilitySettings.NONE
)
class SongController (override val service: SongService, userService: UserService)
    : IControllerImpl<Song, SongReadDTO, SongCreateDTO, SongUpdateDTO>(service, userService) {

    @PatchMapping("/{id}")
    @ResponseStatus(HttpStatus.OK)
    override fun update(@PathVariable id: Int, @RequestBody dto: SongUpdateDTO, request: HttpServletRequest)
    = authenticate(request, { it.update }) { user ->
        val header = request.getHeader("If-Unmodified-Since") ?: ""
        val lastModified = try { sdf.parse(header).time } catch (exc: Exception) { 0 }

        // Support for Conditional PUT
        val song = service.getByID(id, user)
        if (lastModified != 0L && song.lastEdit.time > lastModified)
            throw ResponseStatusException(HttpStatus.PRECONDITION_FAILED)
        super.update(id, dto, request)
    }

    // TODO: Authentication in the future

    @GetMapping("/{id}/opensong")
    fun exportAsOpenSong(@PathVariable id: Int, response: HttpServletResponse)
        = ResponseEntity(service.exportAsOpenSong(id), HttpHeaders().apply {
            add("Content-Disposition", "attachment; filename=\"${service.getSongName(id).normalized}.xml\"")
            acceptCharset = listOf(Charsets.UTF_8)
        }, HttpStatus.OK)

    @GetMapping("/{id}/text")
    fun exportAsText(@PathVariable id: Int)
        = ResponseEntity(service.exportAsText(id), HttpHeaders().apply {
            add("Content-Disposition", "attachment; filename=\"${service.getSongName(id).normalized}.txt\"")
        }, HttpStatus.OK)

}

// Helper extension property for String normalization
val String.normalized: String
    get() = Normalizer.normalize(this, Normalizer.Form.NFD)
        .replace(Regex("\\p{InCombiningDiacriticalMarks}+"), "")