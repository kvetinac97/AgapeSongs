package cz.fit.cvut.wrzecond.agapesongs.entity

import javax.persistence.*

@Entity
data class Band (
    @Column(nullable = false) val name: String,
    @Column(nullable = false) val secret: String,
    @Column(nullable = false) val playlist: String,
    @OneToMany(mappedBy = "band")
    val members: List<BandMember>,
    @OneToMany(mappedBy = "band")
    val songBooks: List<SongBook>,
    override val id: Int = 0
) : IEntity(id) {
    override fun canEdit (user: User)
        = user.bands.any { it.role.level == RoleLevel.LEADER && it.band.id == id }

    override fun canView (user: User?)
        = user?.bands?.any { it.band.id == id } ?: false
}
