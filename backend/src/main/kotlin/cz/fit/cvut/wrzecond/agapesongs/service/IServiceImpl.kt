package cz.fit.cvut.wrzecond.agapesongs.service

import cz.fit.cvut.wrzecond.agapesongs.dto.ICreateDTO
import cz.fit.cvut.wrzecond.agapesongs.dto.IReadDTO
import cz.fit.cvut.wrzecond.agapesongs.dto.IUpdateDTO
import cz.fit.cvut.wrzecond.agapesongs.dto.UserReadDTO
import cz.fit.cvut.wrzecond.agapesongs.entity.IEntity
import cz.fit.cvut.wrzecond.agapesongs.repository.IRepository
import cz.fit.cvut.wrzecond.agapesongs.repository.UserRepository
import org.springframework.data.domain.Sort
import org.springframework.http.HttpStatus
import org.springframework.web.server.ResponseStatusException

abstract class IServiceImpl<T: IEntity, R: IReadDTO, C: ICreateDTO, U: IUpdateDTO> (override val repository: IRepository<T>, userRepository: UserRepository)
    : IServiceBase<T>(repository, userRepository), IService<T, R, C, U> {

    /** Default sort */
    override val sort: Sort
        get () = Sort.unsorted()

    /** Helper method to get entity with given ID */
    private fun getEntityByID (id: Int) = tryCatch { repository.getById(id) }

    /** Helper method throwing unauthorized/forbidden response for edit */
    private fun <X> checkEditAccess (entity: T, dto: UserReadDTO?, block: (T) -> X) = tryCatch {
        if (!entity.canEdit(getUser(dto))) throw ResponseStatusException(HttpStatus.FORBIDDEN)
        block(entity)
    }

    /** Helper method throwing unauthorized/forbidden response for view */
    private fun <X> checkViewAccess (entity: T, dto: UserReadDTO?, block: (T) -> X) = tryCatch {
        if (!entity.canView(getUser(dto))) throw ResponseStatusException(HttpStatus.FORBIDDEN)
        block(entity)
    }

    // === Default implementation of interface methods ===

    // Get
    override fun getByID (id: Int, user: UserReadDTO?) = checkViewAccess(getEntityByID(id), user) { it.toDTO() }
    override fun findAll (user: UserReadDTO?) = tryCatch {
        val userEntity = try { getUser(user) } catch (_: Exception) { null }
        repository.findAll(sort).filter { it.canView(userEntity) }.map { it.toDTO() }
    }

    // Create, Update, Delete
    override fun create (dto: C, user: UserReadDTO?) = checkEditAccess(dto.toEntity(), user) { repository.saveAndFlush(it).toDTO() }
    override fun update (id: Int, dto: U, user: UserReadDTO?) = checkEditAccess(getEntityByID(id), user) { entity ->
        checkEditAccess(entity.merge(dto), user) { repository.saveAndFlush(it).toDTO() }
    }
    override fun delete (id: Int, user: UserReadDTO?) = checkEditAccess(getEntityByID(id), user) { repository.delete(it) }

    // === Default implementation of interface methods ===

}
