package cz.fit.cvut.wrzecond.agapesongs.repository

import cz.fit.cvut.wrzecond.agapesongs.entity.Band
import org.springframework.data.jpa.repository.Query
import org.springframework.stereotype.Repository

@Repository
interface BandRepository : IRepository<Band> {

    @Query("SELECT b FROM Band b WHERE b.secret = :secret")
    fun getBySecret (secret: String) : Band?

}
