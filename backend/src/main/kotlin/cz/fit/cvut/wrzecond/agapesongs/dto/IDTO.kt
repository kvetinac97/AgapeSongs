package cz.fit.cvut.wrzecond.agapesongs.dto

/**
 * General CreateDTO interface
 * used for entity creation in POST collection requests
 * all fields must be not-null, as entity is being created
 * there is NO id field, as it will be auto-generated
 */
interface ICreateDTO

/**
 * General UpdateDTO interface
 * used for entity update in PATCH requests
 * fields can be null, as we can want only to update part of entity
 * there is NO id field, as it is part of request path
 */
interface IUpdateDTO

/**
 * General ReadDTO interface
 * used for entity reading in GET requests
 * nullability of fields reflects nullability of database fields
 */
interface IReadDTO {
    /** Unique identifier of entity */
    val id: Int
}
