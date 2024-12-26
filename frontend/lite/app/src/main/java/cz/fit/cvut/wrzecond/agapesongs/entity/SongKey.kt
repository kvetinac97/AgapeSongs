package cz.fit.cvut.wrzecond.agapesongs.entity

/**
 * Enum class representing possible song keys
 */
enum class SongKey(val keyPosition: Int, val localized: String) {
    // Keys
    C_SHARP (1, "C#"), C (0, "C"),
    D_FLAT (1, "Db"), D_SHARP (3, "D#"), D (2, "D"),
    E_FLAT (3, "Eb"), E (4, "E"),
    F_SHARP (6, "F#"), F (5, "F"),
    G_FLAT (6, "Gb"), G_SHARP (8, "G#"), G (7, "G"),
    A_FLAT (8, "Ab"), A_SHARP (10, "A#"), A (9, "A"),
    B_FLAT (10, "B"), B (11, "H");

    fun transpose(steps: Int, keys: List<SongKey>)
            = keys[(((keyPosition + steps) % 12) + 12) % 12]

    companion object {
        val flats
            get() = listOf(C, D_FLAT, D, E_FLAT, E, F, G_FLAT, G, A_FLAT, A, B_FLAT, B)
        val sharps
            get() = listOf(C, C_SHARP, D, D_SHARP, E, F, F_SHARP, G, G_SHARP, A, B_FLAT, B)
    }
}
