package cz.fit.cvut.wrzecond.agapesongs.entity

import org.hibernate.annotations.OnDelete
import org.hibernate.annotations.OnDeleteAction
import javax.persistence.*

@Entity
@Table (uniqueConstraints=[UniqueConstraint(columnNames = ["band_id", "user_id"])])
data class BandMember (
    @ManyToOne
    @OnDelete (action = OnDeleteAction.CASCADE)
    @JoinColumn (name = "band_id", nullable = false)
    val band: Band,

    @ManyToOne
    @OnDelete (action = OnDeleteAction.CASCADE)
    @JoinColumn (name = "user_id", nullable = false)
    val user: User,

    @ManyToOne
    @OnDelete (action = OnDeleteAction.CASCADE)
    @JoinColumn (name = "role_id", nullable = false)
    val role: Role,

    override val id: Int = 0
) : IEntity(id) {
    override fun canEdit (user: User)
        = band.canEdit(user)

    override fun canView (user: User?)
        = band.canView(user)
}
