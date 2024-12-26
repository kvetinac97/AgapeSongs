package cz.fit.cvut.wrzecond.agapesongs.entity

import javax.persistence.*

@Entity
@Table (uniqueConstraints=[UniqueConstraint(columnNames = ["name", "band_id"])])
data class SongBook (
    @Column(nullable = false) val name: String,
    @OneToMany(mappedBy = "songBook")
    val songs: List<Song>,

    @ManyToOne
    @JoinColumn (name = "band_id", nullable = false)
    val band: Band,
    override val id: Int = 0
) : IEntity(id) {
    override fun canEdit (user: User)
        = user.bands.any { it.role.level == RoleLevel.LEADER && it.band.id == band.id }
    override fun canView (user: User?)
        = user?.bands?.any { it.band.id == band.id } ?: false
}
