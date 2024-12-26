package cz.fit.cvut.wrzecond.agapesongs.controller

import cz.fit.cvut.wrzecond.agapesongs.dto.ICreateDTO
import cz.fit.cvut.wrzecond.agapesongs.dto.IReadDTO
import cz.fit.cvut.wrzecond.agapesongs.dto.IUpdateDTO
import cz.fit.cvut.wrzecond.agapesongs.dto.UserReadDTO
import cz.fit.cvut.wrzecond.agapesongs.entity.IEntity
import cz.fit.cvut.wrzecond.agapesongs.service.IService
import org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.*
import org.springframework.web.server.ResponseStatusException
import javax.servlet.http.HttpServletRequest
import javax.servlet.http.HttpServletResponse

/**
 * Generic controller interface
 * automatically creates CRUD methods and maps them
 */
interface IController<T: IEntity, R: IReadDTO, C: ICreateDTO, U: IUpdateDTO> {

    /** Service performing all logic on given DTOs */
    val service: IService<T, R, C, U>

    /**
     * Find all entities
     * @return list of Read DTO reflecting all entities
     */
    @GetMapping
    fun all (request: HttpServletRequest) : List<R>

    /**
     * Gets ReadDTO of entity with given ID
     * @param id ID of entity
     * @param request HTTP request, could be used for authentication
     * @throws ResponseStatusException with code 404 if entity was not found
     * @return Read DTO of entity with given ID
     */
    @GetMapping("/{id}")
    fun getByID (@PathVariable id: Int, request: HttpServletRequest) : R

    /**
     * Create entity based on given create DTO
     * @param dto Create DTOs to create entity
     * @param request HTTP request, could be used for authentication
     * @param response HTTP response. On success, 'Location' header with created entity ID is added
     * @throws ResponseStatusException with code 400 if create DTO is invalid
     * @return Read DTO of created entity
     */
    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    fun create (@RequestBody dto: C, request: HttpServletRequest, response: HttpServletResponse) : R

    /**
     * Update entity based on given update DTO
     * @param id ID of entity being updated
     * @param dto Update DTO to update entity with
     * @param request HTTP request, could be used for authentication
     * @throws ResponseStatusException with code 400 if create DTOs are invalid
     * @throws ResponseStatusException with code 404 if entity was not found
     * @return Read DTO of updated entity
     */
    @PatchMapping("/{id}")
    @ResponseStatus(HttpStatus.OK)
    fun update (@PathVariable id: Int, @RequestBody dto: U, request: HttpServletRequest) : R

    /**
     * Delete entity with given ID
     * @param id ID of entity to delete
     * @throws ResponseStatusException with code 404 if entity was not found
     */
    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    fun delete (@PathVariable id: Int, request: HttpServletRequest)

}
