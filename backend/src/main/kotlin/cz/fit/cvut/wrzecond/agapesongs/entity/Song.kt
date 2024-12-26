package cz.fit.cvut.wrzecond.agapesongs.entity

import org.hibernate.annotations.OnDelete
import org.hibernate.annotations.OnDeleteAction
import java.sql.Timestamp
import javax.persistence.*

@Entity
@Table (uniqueConstraints=[UniqueConstraint(columnNames = ["name", "songbook_id"])])
data class Song (
    @Column(nullable = false) val name: String,
    @Lob @Column(nullable = false) val text: String,
    @Column(nullable = false, name = "song_key") val key: String,
    @Column(nullable = false) val bpm: Int,
    @Column(nullable = false, name = "song_beat") val beat: String,
    @Column(nullable = false) val capo: Int,
    @Column(nullable = false) val lastEdit: Timestamp,
    @Column(nullable = true) val displayId: Int?,

    @ManyToOne
    @OnDelete (action = OnDeleteAction.CASCADE)
    @JoinColumn (name = "songbook_id", nullable = false)
    val songBook: SongBook,
    override val id: Int = 0
) : IEntity(id) {
    override fun canEdit (user: User)
        = user.bands.any { (it.role.level == RoleLevel.MUSICIAN || it.role.level == RoleLevel.LEADER)
            && it.band.id == songBook.band.id }

    override fun canView (user: User?)
        = songBook.canView(user)
}
