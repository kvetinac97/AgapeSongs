package cz.fit.cvut.wrzecond.agapesongs.dto

/**
 * Data transfer object for getting / updating playlist
 * @property songs array of song ids in playlist
 */
data class PlaylistDTO (val songs: List<Int>)
