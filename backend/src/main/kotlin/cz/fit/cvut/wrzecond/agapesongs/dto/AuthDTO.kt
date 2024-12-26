package cz.fit.cvut.wrzecond.agapesongs.dto

/**
 * Data transfer object for authenticating with Apple
 * @property code the authorization code gained from Apple
 * @property name first and last name of user being signed in
 */
data class AuthDTO (val code: String, val name: String? = null)
