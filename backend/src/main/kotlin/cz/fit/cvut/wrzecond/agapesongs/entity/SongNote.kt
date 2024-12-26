package cz.fit.cvut.wrzecond.agapesongs.entity

import org.hibernate.annotations.OnDelete
import org.hibernate.annotations.OnDeleteAction
import java.sql.Timestamp
import javax.persistence.*

@Entity
@Table (uniqueConstraints=[UniqueConstraint(columnNames = ["song_id", "user_id"])])
data class SongNote (
    @ManyToOne
    @OnDelete (action = OnDeleteAction.CASCADE)
    @JoinColumn (name = "song_id", nullable = false)
    val song: Song,

    @ManyToOne
    @OnDelete (action = OnDeleteAction.CASCADE)
    @JoinColumn (name = "user_id", nullable = false)
    val user: User,

    @Column(nullable = false) val notes: String,
    @Column(nullable = false) val capo: Int,
    @Column(nullable = false) val lastEdit: Timestamp,
    override val id: Int = 0
) : IEntity(id) {
    override fun canEdit (user: User)
        = canView(user)

    override fun canView(user: User?)
        = this.user.id == user?.id && song.canEdit(user)
}
