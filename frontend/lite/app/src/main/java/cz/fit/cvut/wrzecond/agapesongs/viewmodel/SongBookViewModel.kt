package cz.fit.cvut.wrzecond.agapesongs.viewmodel

import android.app.Application
import android.util.Log
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import cz.fit.cvut.wrzecond.agapesongs.entity.Band
import cz.fit.cvut.wrzecond.agapesongs.entity.Playlist
import cz.fit.cvut.wrzecond.agapesongs.entity.SongBook
import cz.fit.cvut.wrzecond.agapesongs.api.RestClient
import cz.fit.cvut.wrzecond.agapesongs.entity.Song
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch
import retrofit2.awaitResponse
import java.lang.reflect.Type

class SongBookViewModel(application: Application) : AndroidViewModel(application) {
    // Editable lists
    private val _songBookList = MutableStateFlow(Result(state = State.Loading, songBookList = listOf()))
    private val _playList = MutableStateFlow(PlaylistResult(state = State.Loading, playlist = SongBook(-1, "Playlist",
        Band(-1, "Any", emptyList()), emptyList())))

    // Lists
    val songBookList: StateFlow<Result> get() = _songBookList
    val playList: StateFlow<PlaylistResult> get() = _playList
    val hiddenSongBookList = MutableStateFlow(listOf<Int>())

    // Properties
    val loginSecret = MutableStateFlow<String?>(null)
    val searchText = MutableStateFlow("")
    val searching = MutableStateFlow(false)

    init {
        val preferences = getApplication<Application>().getSharedPreferences("SONG_LIST", Application.MODE_PRIVATE)

        hiddenSongBookList.value = Gson().fromJson(preferences.getString("HIDDEN_LIST", "[]"), intListType)
        viewModelScope.launch {
            hiddenSongBookList.collect { hiddenList ->
                preferences.edit().putString("HIDDEN_LIST", Gson().toJson(hiddenList)).apply()
            }
        }
        viewModelScope.launch {
            loginSecret.collect { loginSecret ->
                if (loginSecret != null)
                    fetchSongBookList()
            }
        }

        if (preferences.contains("LOGIN_SECRET"))
            loginSecret.value = preferences.getString("LOGIN_SECRET", "")
    }

    private val intListType: Type
        get() = object: TypeToken<List<Int>>(){}.type
    private val songLineDtoType: Type
        get() = object: TypeToken<List<SongBook>>(){}.type

    fun fetchSongBookList()
        = viewModelScope.launch {
            val preferences = getApplication<Application>().getSharedPreferences("SONG_LIST", Application.MODE_PRIVATE)
            val loginSecret = loginSecret.value ?: return@launch
            try {
                val call = RestClient().getService().fetchSongBookList(loginSecret)
                val response = call?.awaitResponse()
                val resultUnmerged = response?.body()

                if (resultUnmerged == null) {
                    this@SongBookViewModel.loginSecret.value = null
                    return@launch
                }

                val result = if (loginSecret.endsWith("SPECIAL_SECRET")) {
                    val songs = mutableListOf<Song>()
                    resultUnmerged.forEach { songs.addAll(it.songs) }
                    listOf(SongBook(1, "Všechno", resultUnmerged.first().band, songs.sortedBy { it.name }))
                }
                else resultUnmerged

                preferences.edit()
                    .putString("LOGIN_SECRET", loginSecret) // successful login = save login secret
                    .putString("LIST_JSON", Gson().toJson(result)) // save for backup
                    .apply()
                _songBookList.emit(Result(state = State.Success, songBookList = result))
            } catch (e: Exception) {
                Log.e("AgapeSongs", e.message ?: "", e)
                val backup = preferences.getString("LIST_JSON", null)?.let { Gson().fromJson<List<SongBook>>(it, songLineDtoType) }
                if (backup == null)
                    _songBookList.emit(Result(state = State.Failed, songBookList = listOf()))
                else
                    _songBookList.emit(Result(state = State.Success, songBookList = backup))
            }

            val playlist = preferences.getString("PLAYLIST_JSON", "{\"songs\":[]}").let {
                Gson().fromJson(it, Playlist::class.java)
            }
            emitPlaylist(playlist.songs)
        }

    fun fetchPlaylist(id: Int)
        = viewModelScope.launch {
            val preferences = getApplication<Application>().getSharedPreferences("SONG_LIST", Application.MODE_PRIVATE)
            try {
                val call = RestClient().getService().fetchPlaylist(loginSecret.value ?: "", id)
                val response = call?.awaitResponse()
                val result = response?.body() ?: throw Exception("Null response")
                preferences.edit().putString("PLAYLIST_JSON", Gson().toJson(result)).apply() // save for backup
                emitPlaylist(result.songs)
            } catch (e: Exception) {
                Log.e("AgapeSongs", e.message ?: "", e)
            }
        }

    fun logout() {
        loginSecret.value = null
        val preferences = getApplication<Application>().getSharedPreferences("SONG_LIST", Application.MODE_PRIVATE)
        preferences.edit().remove("LOGIN_SECRET").apply()
    }

    private suspend fun emitPlaylist(playlist: List<Int>) {
        val songs = songBookList.value.songBookList.flatMap { it.songs }
        _playList.emit(PlaylistResult(state = State.Success, playlist = SongBook(
            id = -1,
            name = "Playlist",
            band = Band(-1, "Any", emptyList()),
            songs = playlist.mapNotNull { songId ->
                return@mapNotNull songs.firstOrNull { it.id == songId }
            }
        )))
    }
}

data class Result(val state: State, val songBookList: List<SongBook>)
data class PlaylistResult(val state: State, val playlist: SongBook)
enum class State { Success, Failed, Loading }
