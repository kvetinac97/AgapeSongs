package cz.fit.cvut.wrzecond.agapesongs.api

import cz.fit.cvut.wrzecond.agapesongs.entity.Playlist
import cz.fit.cvut.wrzecond.agapesongs.entity.SongBook
import retrofit2.Call
import retrofit2.http.GET
import retrofit2.http.Header
import retrofit2.http.Path

interface Api {
    @GET("/songbook")
    fun fetchSongBookList(@Header("LOGIN_SECRET") loginSecret: String) : Call<List<SongBook>>?

    @GET("/band/{id}/playlist")
    fun fetchPlaylist(@Header("LOGIN_SECRET") loginSecret: String, @Path("id") id: Int) : Call<Playlist>?
}
