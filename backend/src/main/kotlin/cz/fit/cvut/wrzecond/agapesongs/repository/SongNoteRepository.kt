package cz.fit.cvut.wrzecond.agapesongs.repository

import cz.fit.cvut.wrzecond.agapesongs.entity.Song
import cz.fit.cvut.wrzecond.agapesongs.entity.User
import cz.fit.cvut.wrzecond.agapesongs.entity.SongNote
import org.springframework.data.jpa.repository.Query

interface SongNoteRepository : IRepository<SongNote> {

    @Query("SELECT note FROM SongNote note WHERE note.user = :user")
    fun findByUser (user: User) : List<SongNote>

    @Query("SELECT note FROM SongNote note WHERE note.song = :song AND note.user = :user")
    fun getBySongAndUser (song: Song, user: User) : SongNote?

}
