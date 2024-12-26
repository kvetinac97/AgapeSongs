package cz.fit.cvut.wrzecond.agapesongs.repository

import cz.fit.cvut.wrzecond.agapesongs.entity.User
import org.springframework.data.jpa.repository.Query
import org.springframework.stereotype.Repository

@Repository
interface UserRepository : IRepository<User> {

    @Query("SELECT u FROM User u WHERE u.email = :email")
    fun getByEmail (email: String) : User?

    @Query("SELECT u FROM User u WHERE u.loginSecret = :loginSecret")
    fun getByLoginSecret (loginSecret: String) : User?

}
