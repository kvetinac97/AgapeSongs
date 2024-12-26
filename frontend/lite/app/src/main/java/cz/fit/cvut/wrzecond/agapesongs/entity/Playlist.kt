package cz.fit.cvut.wrzecond.agapesongs.entity

/**
 * Data transfer object for getting / updating playlist
 * @property songs array of song ids in playlist
 */
data class Playlist (val songs: List<Int>)
