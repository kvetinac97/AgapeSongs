package cz.fit.cvut.wrzecond.agapesongs.service

import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import cz.fit.cvut.wrzecond.agapesongs.dto.*
import cz.fit.cvut.wrzecond.agapesongs.entity.*
import cz.fit.cvut.wrzecond.agapesongs.repository.SongBookRepository
import cz.fit.cvut.wrzecond.agapesongs.repository.SongRepository
import cz.fit.cvut.wrzecond.agapesongs.repository.UserRepository
import org.springframework.stereotype.Service
import java.sql.Timestamp
import java.time.Instant
import kotlin.random.Random

@Service
class SongService (override val repository: SongRepository, val songBookRepository: SongBookRepository, userRepository: UserRepository)
    : IServiceImpl<Song, SongReadDTO, SongCreateDTO, SongUpdateDTO>(repository, userRepository) {

    /** Function to convert song text from JSON to array of SongLineReadDTO */
    fun convertSongText(text: String): List<SongLineReadDTO> = tryCatch {
        val songLineDtoListType = object: TypeToken<List<SongLineReadDTO>>(){}.type
        Gson().fromJson(text, songLineDtoListType)
    }

    /** Function to get song name with id */
    fun getSongName(id: Int) = tryCatch {
        "${getById(id).name} ${String.format("%03d", id)}"
    }

    /** Function to export song with given identifier in OpenSong format */
    fun exportAsOpenSong(id: Int) = tryCatch {
        val song = getById(id)
        val lines = convertSongText(song.text)

        val text = lines.joinToString("\n") { line ->
            (line.chords?.let { ".$it\n" } ?: "") + " ${line.text}"
        }

        "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<song>\n  <title>${song.name}</title>\n" +
        "  <author></author>\n  <copyright></copyright>\n  <presentation></presentation>\n" +
        "  <hymn_number></hymn_number>\n  <capo print=\"false\">${song.capo}</capo>\n" +
        "  <tempo>${song.bpm}</tempo>\n  <time_sig></time_sig>\n  <duration></duration>\n" +
        "  <predelay></predelay>\n  <ccli></ccli>\n  <theme></theme>\n  <alttheme></alttheme>\n" +
        "  <user1></user1>\n  <user2></user2>\n  <user3></user3>\n  <key>${song.key}</key>\n" +
        "  <aka></aka>\n  <key_line></key_line>\n  <books></books>\n  <midi></midi>\n" +
        "  <midi_index></midi_index>\n  <pitch></pitch>\n  <restrictions></restrictions>\n" +
        "  <notes></notes>\n  <lyrics>$text</lyrics>\n  <linked_songs></linked_songs>\n" +
        "  <pad_file>Auto</pad_file>\n  <custom_chords></custom_chords>\n  <link_youtube></link_youtube>\n" +
        "  <link_web></link_web>\n  <link_audio></link_audio>\n  <loop_audio>false</loop_audio>\n" +
        "  <link_other></link_other>\n" +
        "  <backgrounds resize=\"screen\" keep_aspect=\"false\" link=\"false\" background_as_text=\"false\"/>\n" +
        "</song>"
    }

    /** Function to export song with given identifier in plaintext */
    fun exportAsText(id: Int) = tryCatch {
        val song = getById(id)
        val lines = convertSongText(song.text)
        lines.joinToString("\n") { line ->
            (line.chords?.let { "$it\n" } ?: "") + line.text
        }
    }

    /**
     * Converts OpenSong text to custom JSON format
     * @property text the text to convert
     * @return JSON representation of given text
     */
    private fun convertTextToJson(text: String) = tryCatch {
        val textLines = text.split("\n")
        val songLineDtoList = textLines.mapIndexed { index, rawLine ->
            val line = rawLine.trimEnd()
            when (line.firstOrNull()) {
                // text line
                ' ' -> {
                    val chordLine = textLines.getOrNull(index - 1).let { prevLine ->
                        if (prevLine?.firstOrNull() == '.') prevLine.drop(1)
                        else null
                    }
                    SongLineReadDTO(
                        generateRandomId(),
                        chordLine,
                        line.drop(1)
                    )
                }
                '.' -> null // chords are already parsed with text

                // parse this line "as is"
                else -> SongLineReadDTO(generateRandomId(), null, line)
            }
        }.filterNotNull()

        // Return resulting lines
        Gson().toJson(songLineDtoList)
    }

    // === INTERFACE METHOD IMPLEMENTATION ===
    override fun Song.toDTO () = SongReadDTO(id, songBook.toDTO(), name, convertSongText(text),
        SongKey.valueOf(key), bpm, SongBeat.valueOf(beat), capo, lastEdit, displayId, null)
    override fun SongCreateDTO.toEntity () = Song(name, convertTextToJson(text), key.name, bpm,
        beat?.name ?: SongBeat.FOUR_FOURTHS.name, capo, Timestamp.from(Instant.now()),
        displayId, songBookRepository.getById(songBookId))
    override fun Song.merge (dto: SongUpdateDTO) = copy(
        name = dto.name ?: name,
        text = dto.text?.let { convertTextToJson(it) } ?: text,
        key = dto.key?.name ?: key,
        bpm = dto.bpm ?: bpm,
        beat = dto.beat?.name ?: beat,
        capo = dto.capo ?: capo,
        lastEdit = Timestamp.from(Instant.now()),
        displayId = dto.displayId,
        songBook = dto.songBookId?.let { songBookRepository.getById(it) } ?: songBook
    )
    // === INTERFACE METHOD IMPLEMENTATION ===

    // === HELPER METHODS ===
    private fun SongBook.toDTO () = SongBookReadDTO(id, name, band.toDTO(), emptyList())
    private fun Band.toDTO () = BandReadDTO(id, name, "", members.map { it.toDTO() })
    private fun BandMember.toDTO () = BandMemberReadDTO(id, BandReadDTO(band.id,
        band.name, "", emptyList()), user.toDTO(), role.toDTO())
    private fun User.toDTO () = UserReadDTO(id, email, name, emptyList())
    private fun Role.toDTO () = RoleReadDTO(id, level.name)

    private fun generateRandomId () = (1..ID_LENGTH)
        .map { Random.nextInt(0, CHAR_POOL.size) }
        .map(CHAR_POOL::get)
        .joinToString("")
    // === HELPER METHODS ===

    companion object {
        private const val ID_LENGTH = 8
        private val CHAR_POOL = ('a'..'z') + ('A'..'Z') + ('0'..'9')
    }
}
