package cz.fit.cvut.wrzecond.agapesongs.ui

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.rounded.KeyboardArrowLeft
import androidx.compose.material.icons.rounded.KeyboardArrowRight
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.buildAnnotatedString
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.withStyle
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import cz.fit.cvut.wrzecond.agapesongs.entity.Song
import cz.fit.cvut.wrzecond.agapesongs.viewmodel.SongBookViewModel
import cz.fit.cvut.wrzecond.agapesongs.viewmodel.SongViewModel

@Composable
fun SongDetail(songBookViewModel: SongBookViewModel, songViewModel: SongViewModel, navigateToList: () -> Unit) {
    val song = songViewModel.song.value ?: return
    AgapeSongsTheme {
        Scaffold(
            topBar = {
                SongDetailTopBar(
                    song, navigateToList,
                    changeSize = { songViewModel.fontSize.value += it },
                    changeCapo = { songViewModel.capo.value += it }
                )
            },
            backgroundColor = Color.White,
            floatingActionButton = { SongDetailFA(songBookViewModel, songViewModel) }
        ) { padding -> Box(Modifier.padding(padding)) { SongDetailContent(songViewModel) } }
    }
}

@Composable
fun SongDetailTopBar(song: Song, navigateToList: () -> Unit, changeSize: (Int) -> Unit, changeCapo: (Int) -> Unit) {
    TopAppBar(
        backgroundColor = MaterialTheme.colors.primarySurface,
        elevation = 4.dp,
        title = { Text("${song.name} ${song.displayId?.let { String.format("%03d", it) } ?: ""}") },
        navigationIcon = {
            IconButton(onClick = navigateToList) { Icon(Icons.Filled.ArrowBack, null) }
        },
        actions = {
            IconButton(onClick = { changeSize(-3) }) {
                Icon(Icons.Filled.KeyboardArrowLeft, null)
            }
            IconButton(onClick = { changeSize(3) }) {
                Icon(Icons.Filled.KeyboardArrowRight, null)
            }
            IconButton(onClick = { changeCapo(-1) }) {
                Icon(Icons.Filled.KeyboardArrowDown, null)
            }
            IconButton(onClick = { changeCapo(1) }) {
                Icon(Icons.Filled.KeyboardArrowUp, null)
            }
        }
    )
}

@Composable
fun SongDetailFA(songBookViewModel: SongBookViewModel, songViewModel: SongViewModel) {
    val song = songViewModel.song.value ?: return
    Row(
        Modifier
            .fillMaxWidth()
            .padding(16.dp)) {
        val playlist = songBookViewModel.playList.collectAsState()
        val playlistPos = playlist.value.playlist.songs.indexOfFirst { it.id == song.id }
        if (playlistPos > 0)
            SongDetailFAB(Icons.Rounded.KeyboardArrowLeft) {
                songViewModel.changeSong(playlist.value.playlist.songs, -1)
            }
        Spacer(Modifier.weight(1F))
        if (playlistPos != -1 && playlistPos != playlist.value.playlist.songs.size - 1)
            SongDetailFAB(Icons.Rounded.KeyboardArrowRight) {
                songViewModel.changeSong(playlist.value.playlist.songs, 1)
            }
    }
}

@Composable
fun SongDetailFAB(icon: ImageVector, clickAction: () -> Unit) {
    IconButton(onClick = clickAction) {
        Icon(
            icon,
            contentDescription = null,
            tint = Color.Blue.copy(alpha = 0.5F),
            modifier = Modifier.size(64.dp)
        )
    }
}

@Composable
fun SongDetailContent(songViewModel: SongViewModel) {
    SongDetailContentCalculation(songViewModel)
    SongDetailContentText(songViewModel)
}

@Composable
fun SongDetailContentCalculation(songViewModel: SongViewModel) {
    val fontSize = songViewModel.fontSize.collectAsState()
    val screenWidth = remember { mutableStateOf(0) }
    val textWidth = remember { mutableStateOf(0) }
    Text("X", Modifier.fillMaxWidth(),
        fontSize = fontSize.value.sp, color = Color.White,
        fontFamily = FontFamily.Monospace, onTextLayout = {
            screenWidth.value = it.size.width
            if (textWidth.value != 0)
                songViewModel.maxCharacters.value = ((screenWidth.value - 100) / textWidth.value)
        }
    )
    Text("X",
        fontSize = fontSize.value.sp, color = Color.White,
        fontFamily = FontFamily.Monospace, onTextLayout = {
            textWidth.value = it.size.width
            if (screenWidth.value != 0)
                songViewModel.maxCharacters.value = ((screenWidth.value - 100) / textWidth.value)
        }
    )
}

@Composable
fun SongDetailContentText(songViewModel: SongViewModel) {
    val state = rememberScrollState()
    val fontSize = songViewModel.fontSize.collectAsState()
    val capo = songViewModel.capo.collectAsState()
    val maxCharacters = songViewModel.maxCharacters.collectAsState()

    Text(
        modifier = Modifier.padding(16.dp).verticalScroll(state),
        fontSize = fontSize.value.sp,
        text = buildAnnotatedString {
            songViewModel.textWithInformation(maxCharacters.value).forEach { line ->
                capo.value.let { capo ->
                    songViewModel.transpose(capo, line.chords)?.let { chords ->
                        withStyle(SpanStyle(Color.Red, fontFamily = FontFamily.Monospace)) {
                            append("$chords\n")
                        }
                    }
                    withStyle(SpanStyle(Color.Black, fontFamily = FontFamily.Monospace)) {
                        append("${line.text}\n")
                    }
                }
            }
        }
    )
}
