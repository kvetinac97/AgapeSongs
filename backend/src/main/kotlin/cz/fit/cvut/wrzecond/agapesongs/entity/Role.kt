package cz.fit.cvut.wrzecond.agapesongs.entity

import javax.persistence.*

@Entity
data class Role (
    @Column(nullable = false) val level: RoleLevel,
    override val id: Int = 0
) : IEntity(id)

enum class RoleLevel {
    LEADER, MUSICIAN, SINGER
}
