package cz.fit.cvut.wrzecond.agapesongs.entity

import javax.persistence.*

@Entity
data class User (
    @Column(nullable = false, unique = true) val loginSecret: String,
    @Column(nullable = false, unique = true) val email: String,
    @Column(nullable = false) val name: String,
    @OneToMany(mappedBy = "user")
    val bands: List<BandMember>,
    @OneToMany(mappedBy = "user")
    val notes: List<SongNote>,
    override val id: Int = 0,
) : IEntity(id)
