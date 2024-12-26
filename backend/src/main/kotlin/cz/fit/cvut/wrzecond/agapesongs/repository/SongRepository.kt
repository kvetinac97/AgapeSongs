package cz.fit.cvut.wrzecond.agapesongs.repository

import cz.fit.cvut.wrzecond.agapesongs.entity.Song
import org.springframework.data.jpa.repository.Query
import org.springframework.stereotype.Repository

@Repository
interface SongRepository : IRepository<Song> {

    @Query("SELECT song FROM Song song WHERE song.id IN :ids")
    fun findByIds (ids: List<Int>) : List<Song>

}
