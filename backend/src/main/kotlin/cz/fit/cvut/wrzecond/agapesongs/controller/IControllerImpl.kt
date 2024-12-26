package cz.fit.cvut.wrzecond.agapesongs.controller

import cz.fit.cvut.wrzecond.agapesongs.dto.ICreateDTO
import cz.fit.cvut.wrzecond.agapesongs.dto.IReadDTO
import cz.fit.cvut.wrzecond.agapesongs.dto.IUpdateDTO
import cz.fit.cvut.wrzecond.agapesongs.entity.IEntity
import cz.fit.cvut.wrzecond.agapesongs.service.IService
import cz.fit.cvut.wrzecond.agapesongs.service.UserService
import org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.*
import java.text.SimpleDateFormat
import java.util.*
import javax.servlet.http.HttpServletRequest
import javax.servlet.http.HttpServletResponse

/**
 * Basic controller implementation
 * allows all CRUD methods (when authed)
 */
abstract class IControllerImpl<T: IEntity, R: IReadDTO, C: ICreateDTO, U: IUpdateDTO>
    (override val service: IService<T, R, C, U>, userService: UserService) : IControllerAuth(userService), IController<T, R, C, U> {

    // Helper formatter
    protected val sdf = SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.ENGLISH)

    // === INTERFACE METHOD IMPLEMENTATION ===

    @GetMapping
    override fun all (request: HttpServletRequest)
        = authenticate(request, { it.findAll }) { user -> service.findAll(user) }

    @GetMapping("/{id}")
    override fun getByID (@PathVariable id: Int, request: HttpServletRequest)
        = authenticate(request, { it.getByID }) { user -> service.getByID(id, user) }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    override fun create (@RequestBody dto: C, request: HttpServletRequest, response: HttpServletResponse)
        = authenticate(request, { it.create }) { user -> service.create(dto, user) }

    @PatchMapping("/{id}")
    @ResponseStatus(HttpStatus.OK)
    override fun update (@PathVariable id: Int, @RequestBody dto: U, request: HttpServletRequest)
        = authenticate(request, { it.update }) { user -> service.update(id, dto, user) }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    override fun delete (@PathVariable id: Int, request: HttpServletRequest)
        = authenticate(request, { it.delete }) { user -> service.delete(id, user) }

    // === INTERFACE METHOD IMPLEMENTATION ===

}
