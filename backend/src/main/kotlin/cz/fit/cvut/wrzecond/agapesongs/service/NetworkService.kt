package cz.fit.cvut.wrzecond.agapesongs.service

import io.ktor.client.*
import io.ktor.client.call.*
import io.ktor.client.engine.java.*
import io.ktor.client.features.json.*
import io.ktor.client.request.forms.*
import io.ktor.client.statement.*
import io.ktor.http.*
import kotlinx.coroutines.runBlocking
import org.springframework.stereotype.Service

@Service
class NetworkService {

    /** HttpClient used for network requests to Apple servers */
    private val client = HttpClient(Java) {
        install(JsonFeature) {
            serializer = GsonSerializer {}
        }
    }

    /**
     * Function to sign in with Apple
     * @param code token used for authentication
     * @param secret temporally generated Json Web Token for request security
     * @return JSON String containing Sign in with Apple login information
     * @throws Exception on failure
     */
    fun appleAuthRequest (code: String, secret: String) : String = runBlocking {
        client.submitForm<HttpStatement>(
            url = AuthService.APPLE_ENDPOINT + AuthService.APPLE_PATH,
            formParameters = Parameters.build {
                append("client_id", AuthService.CLIENT_ID)
                append("client_secret", secret)
                append("grant_type", "authorization_code")
                append("code", code)
            }
        )
        .execute()
        .receive()
    }

}
