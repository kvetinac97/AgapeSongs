package cz.fit.cvut.wrzecond.agapesongs.service

import cz.fit.cvut.wrzecond.agapesongs.dto.UserReadDTO
import cz.fit.cvut.wrzecond.agapesongs.entity.IEntity
import cz.fit.cvut.wrzecond.agapesongs.repository.IRepository
import cz.fit.cvut.wrzecond.agapesongs.repository.UserRepository
import org.springframework.dao.EmptyResultDataAccessException
import org.springframework.http.HttpStatus
import org.springframework.orm.jpa.JpaObjectRetrievalFailureException
import org.springframework.web.server.ResponseStatusException

/**
 * Abstract class containing base helper methods
 */
abstract class IServiceBase<T: IEntity> (open val repository: IRepository<T>, private val userRepository: UserRepository) {

    /**
     * Helper method for getting User object from UserReadDTO
     * @throws ResponseStatusException with code 401 when unauthenticated
     * @throws ResponseStatusException with code 403 when unauthorized
     */
    protected fun getUser (dto: UserReadDTO?) =
        try { dto?.let { userRepository.getByEmail(it.email) } ?: throw ResponseStatusException(HttpStatus.UNAUTHORIZED) }
        catch (_: JpaObjectRetrievalFailureException) { throw ResponseStatusException(HttpStatus.UNAUTHORIZED) }
        catch (_: EmptyResultDataAccessException)     { throw ResponseStatusException(HttpStatus.UNAUTHORIZED) }

    /**
     * Helper template function allowing to perform repository action,
     * catch any exception and change it to ResponseStatusException
     * @param block action to perform
     * @return block return value
     */
    protected fun <X> tryCatch (block: IRepository<T>.() -> X) =
        try { repository.block() }
        catch (_: JpaObjectRetrievalFailureException) { throw ResponseStatusException(HttpStatus.NOT_FOUND) }
        catch (_: EmptyResultDataAccessException)     { throw ResponseStatusException(HttpStatus.NOT_FOUND) }
        catch (e: ResponseStatusException)            { throw e } // rethrow ResponseStatusException
        catch (_: Exception)                          { throw ResponseStatusException(HttpStatus.BAD_REQUEST) }

}