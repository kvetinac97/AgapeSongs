package cz.fit.cvut.wrzecond.agapesongs.service

import cz.fit.cvut.wrzecond.agapesongs.dto.ICreateDTO
import cz.fit.cvut.wrzecond.agapesongs.dto.IReadDTO
import cz.fit.cvut.wrzecond.agapesongs.dto.IUpdateDTO
import cz.fit.cvut.wrzecond.agapesongs.dto.UserReadDTO
import cz.fit.cvut.wrzecond.agapesongs.entity.IEntity
import cz.fit.cvut.wrzecond.agapesongs.repository.IRepository
import org.springframework.data.domain.Sort
import org.springframework.web.server.ResponseStatusException

/**
 * Generic interface for service
 * contains definition of basic CRUD operations
 */
interface IService<T: IEntity, R: IReadDTO, C: ICreateDTO, U: IUpdateDTO> {

    /** Repository performing CRUD operations on service entity */
    val repository: IRepository<T>

    /** Default way of sorting data in CRUD get methods */
    val sort: Sort

    /**
     * Gets Read DTO of entity with given ID
     * @param id ID of entity
     * @throws ResponseStatusException with code 404 if entity was not found
     * @throws ResponseStatusException with code 401 if unauthenticated
     * @throws ResponseStatusException with code 403 if unauthorized
     * @return Read DTO of entity with given ID
     */
    fun getByID (id: Int, user: UserReadDTO?) : R

    /**
     * Find all entities in database
     * @return list of Read DTO reflecting all entities user can view
     */
    fun findAll (user: UserReadDTO?) : List<R>

    /**
     * Create entities based on given create DTOs
     * @param dto Create DTO to create entity
     * @param user User DTO of currently logged user, null if unauthenticated
     * @throws ResponseStatusException with code 400 if create DTO is invalid
     * @throws ResponseStatusException with code 401 if unauthenticated
     * @throws ResponseStatusException with code 403 if unauthorized
     * @return Read DTO of created entity
     */
    fun create (dto: C, user: UserReadDTO?) : R

    /**
     * Update entity based on given update DTO
     * @param id ID of entity being updated
     * @param dto Update DTO to update entity with
     * @param user User DTO of currently logged user, null if unauthenticated
     * @throws ResponseStatusException with code 400 if create DTOs are invalid
     * @throws ResponseStatusException with code 404 if entity was not found
     * @throws ResponseStatusException with code 401 if unauthenticated
     * @throws ResponseStatusException with code 403 if unauthorized
     * @return Read DTO of updated entity
     */
    fun update (id: Int, dto: U, user: UserReadDTO?) : R

    /**
     * Delete entity with given ID
     * @param id ID of entity to delete
     * @param user User DTO of currently logged user, null if unauthenticated
     * @throws ResponseStatusException with code 404 if entity was not found
     * @throws ResponseStatusException with code 401 if unauthenticated
     * @throws ResponseStatusException with code 403 if unauthorized
     */
    fun delete (id: Int, user: UserReadDTO?)

    /**
     * Extension function allowing for mapping Entity to Read DTO
     * @return Read DTO reflecting given entity
     */
    fun T.toDTO() : R

    /**
     * Extension function allowing for mapping Create DTO to Entity
     * @return Entity containing all data from given Create DTO
     */
    fun C.toEntity () : T

    /**
     * Extension function allowing for updating Entity with Update DTO
     * For each field of Update DTO, if it is NULL, it should not be updated
     * @param dto Update DTO
     * @return Entity updated with all data from given Update DTO
     */
    fun T.merge(dto: U) : T

}
