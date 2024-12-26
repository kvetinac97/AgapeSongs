package cz.fit.cvut.wrzecond.agapesongs.entity

import javax.persistence.*

/**
 * Generic entity interface
 * (abstract class is used because interfaces cannot have fields)
 */
@MappedSuperclass
abstract class IEntity (
    /** The unique ID of entity */
    @Id
    @GeneratedValue(strategy = GenerationType.TABLE, generator = "id_gen")
    @TableGenerator(name = "id_gen", table = "ids", pkColumnName = "table_name", valueColumnName = "id_value", allocationSize = 1)
    open val id: Int = 0
) {
    open fun canEdit (user: User) = false
    open fun canView (user: User?) = false
}
