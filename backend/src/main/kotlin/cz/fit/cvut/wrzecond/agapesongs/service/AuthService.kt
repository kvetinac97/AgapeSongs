package cz.fit.cvut.wrzecond.agapesongs.service

import com.google.gson.Gson
import cz.fit.cvut.wrzecond.agapesongs.dto.AuthDTO
import cz.fit.cvut.wrzecond.agapesongs.dto.UserLoginDTO
import cz.fit.cvut.wrzecond.agapesongs.entity.*
import cz.fit.cvut.wrzecond.agapesongs.repository.*
import io.jsonwebtoken.JwsHeader
import io.jsonwebtoken.Jwts
import io.jsonwebtoken.SignatureAlgorithm
import io.jsonwebtoken.io.Decoders
import org.bouncycastle.asn1.pkcs.PrivateKeyInfo
import org.bouncycastle.openssl.PEMParser
import org.bouncycastle.openssl.jcajce.JcaPEMKeyConverter
import org.springframework.core.env.Environment
import org.springframework.stereotype.Service
import java.io.FileReader
import java.security.PrivateKey
import java.util.*
import kotlin.random.Random

/**
 * An authentication service serving for Sign with Apple
 * inspired by https://medium.com/tekraze/adding-apple-sign-in-to-spring-boot-app-java-backend-part-e053da331a
 */
@Service
class AuthService(override val repository: UserRepository, private val bandRepository: BandRepository,
                  private val bandMemberRepository: BandMemberRepository, private val roleRepository: RoleRepository,
                  private val songBookRepository: SongBookRepository, private val songRepository: SongRepository,
                  private val networkService: NetworkService, environment: Environment)
    : IServiceBase<User>(repository, repository) {

    /** Environment constant with absolute path to Sign in with Apple key on filesystem */
    private final val keyPath = environment.getProperty("auth.keyPath", "")
    /** Environment constant with Sign in with Apple key identifier */
    private final val keyId   = environment.getProperty("auth.keyId"  , "")
    /** Environment constant with identifier of team used for Sign in with Apple setup */
    private final val teamId  = environment.getProperty("auth.teamId" , "")

    /**
     * This method will try to authenticate given user to Apple servers
     * @param dto data transfer object containing login token from Apple
     * @return UserLoginDTO containing logged-in user secret on success
     * @throws ResponseStatusException with code 400 BAD_REQUEST on failure
     */
    fun authenticate (dto: AuthDTO) = tryCatch {
        val userInfo = appleAuth(dto.code)
        if (!userInfo.email_verified) throw Exception("E-mail is not verified!")

        val user = repository.getByEmail(userInfo.email) ?: createUser(
            userInfo.email, if (dto.name.isNullOrEmpty()) userInfo.email else dto.name
        )
        UserLoginDTO(user.id, user.loginSecret, user.email, user.name)
    }

    // === PRIVATE METHODS ===
    private fun loadKeyFromFile () : PrivateKey {
        val pemParser = PEMParser(FileReader(keyPath))
        val converter = JcaPEMKeyConverter()
        val keyInfo = pemParser.readObject() as PrivateKeyInfo
        return converter.getPrivateKey(keyInfo)
    }

    private fun generateJWT () = Jwts.builder()
        .setHeaderParam(JwsHeader.KEY_ID, keyId)
        .setIssuer(teamId)
        .setAudience(APPLE_ENDPOINT)
        .setSubject(CLIENT_ID)
        .setExpiration(Date(300 * 1000 + System.currentTimeMillis())) // valid for 300 seconds
        .setIssuedAt(Date(System.currentTimeMillis()))
        .signWith(loadKeyFromFile(), SignatureAlgorithm.ES256)
        .compact()

    private fun generateLoginSecret () = (1..LOGIN_SECRET_LENGTH)
        .map { Random.nextInt(0, CHAR_POOL.size) }
        .map(CHAR_POOL::get)
        .joinToString("")

    private fun appleAuth (code: String) : AppleUserInfo = tryCatch {
        val body  = networkService.appleAuthRequest(code, generateJWT())
        val token = Gson().fromJson(body, AppleToken::class.java)
        val payload = token.id_token.split(".")[1]
        val decoded = String(Decoders.BASE64.decode(payload))
        Gson().fromJson(decoded, AppleUserInfo::class.java)
    }

    /**
     * Creates user with given email and name
     * creates band with name of user
     * creates songbook with name Showcase and "Showcase" song inside
     */
    private fun createUser (email: String, name: String)
        = repository.saveAndFlush(User(generateLoginSecret(), email, name, emptyList(), emptyList()))
    // === PRIVATE METHODS ===

    private data class AppleToken (val id_token: String)
    private data class AppleUserInfo (val sub: String, val email: String, val email_verified: Boolean,
                                      val transfer_sub: String?)

    companion object {
        const val APPLE_ENDPOINT = "https://appleid.apple.com"
        const val APPLE_PATH = "/auth/token"
        const val CLIENT_ID = "cz.cvut.fit.wrzecond.AgapeSongs"

        private const val LOGIN_SECRET_LENGTH = 16
        private val CHAR_POOL = ('a'..'z') + ('A'..'Z') + ('0'..'9')
    }
}
