package cz.fit.cvut.wrzecond.agapesongs.ui

import androidx.compose.material.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import cz.fit.cvut.wrzecond.agapesongs.viewmodel.SongBookViewModel
import cz.fit.cvut.wrzecond.agapesongs.viewmodel.SongViewModel

@Composable
fun AgapeSongsApp(songBookViewModel: SongBookViewModel, songViewModel: SongViewModel) {
    val loginSecret = songBookViewModel.loginSecret.collectAsState()
    if (loginSecret.value == null) {
        LoginScreen(songBookViewModel)
        return
    }

    val navController = rememberNavController()
    val selectedSong = songViewModel.song.collectAsState()
    NavHost(navController, startDestination = "songbookList") {
        composable("songbookList") {
            SongBookList(songBookViewModel, songViewModel) {
                navController.navigate("songDetail")
            }
        }
        composable("songDetail") {
            selectedSong.value?.let {
                SongDetail(songBookViewModel, songViewModel) {
                    navController.navigate("songbookList")
                }
            } ?: Text("No song selected")
        }
    }
}
