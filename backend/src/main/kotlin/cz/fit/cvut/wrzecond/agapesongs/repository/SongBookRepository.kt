package cz.fit.cvut.wrzecond.agapesongs.repository

import cz.fit.cvut.wrzecond.agapesongs.entity.Band
import cz.fit.cvut.wrzecond.agapesongs.entity.SongBook
import org.springframework.data.jpa.repository.Query
import org.springframework.stereotype.Repository

@Repository
interface SongBookRepository : IRepository<SongBook> {

    @Query("SELECT sb FROM SongBook sb WHERE sb.band IN :bands")
    fun findByBands(bands: List<Band>) : List<SongBook>

}
