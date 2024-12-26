package cz.fit.cvut.wrzecond.agapesongs.ui

import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.ExperimentalComposeUiApi
import androidx.compose.ui.Modifier
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.focus.focusRequester
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalSoftwareKeyboardController
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import cz.fit.cvut.wrzecond.agapesongs.entity.Song
import cz.fit.cvut.wrzecond.agapesongs.viewmodel.SongViewModel
import cz.fit.cvut.wrzecond.agapesongs.viewmodel.SongBookViewModel
import cz.fit.cvut.wrzecond.agapesongs.viewmodel.State

@Composable
fun SongBookList(songBookViewModel: SongBookViewModel, songViewModel: SongViewModel, navigateToSong: () -> Unit) {
    val songBookList = songBookViewModel.songBookList.collectAsState()
    AgapeSongsTheme {
        Scaffold(topBar = { SongBookListTopBar(songBookViewModel) }) { padding ->
            Box(Modifier.padding(padding)) {
                when (songBookList.value.state) {
                    State.Loading -> SongbookListLoading()
                    State.Failed  -> SongBookListError()
                    State.Success -> SongBookListContent(songBookViewModel, songViewModel, navigateToSong)
                }
            }
        }
    }
}

@Composable
fun SongBookListTopBar(songBookViewModel: SongBookViewModel) {
    val showLogoutDialog = remember { mutableStateOf(false) }
    val searching = songBookViewModel.searching.collectAsState()
    TopAppBar(
        backgroundColor = MaterialTheme.colors.primarySurface,
        elevation = 4.dp,
        title = {
            if (!searching.value) {
                Text("Zpěvníky")
                return@TopAppBar
            }
            val focusRequester = remember { FocusRequester() }
            SongBookListSearchTextField(songBookViewModel, focusRequester)
            LaunchedEffect(Unit) { focusRequester.requestFocus() }
        },
        navigationIcon = {
            IconButton(onClick = { showLogoutDialog.value = true }) {
                Icon(Icons.Filled.Lock, contentDescription = null)
            }
        },
        actions = { SongBookListTopBarNavigation(songBookViewModel) }
    )

    if (showLogoutDialog.value)
        LogoutDialog(songBookViewModel, showLogoutDialog)
}

@Composable
fun LogoutDialog(songBookViewModel: SongBookViewModel, showLogoutDialog: MutableState<Boolean>) {
    AlertDialog(
        onDismissRequest = { showLogoutDialog.value = false },
        title = { Text("Odhlášení") },
        text = { Text("Opravdu se chcete odhlásit? Budete muset znovu zadávat kód.") },
        confirmButton = {
            TextButton(onClick = {
                showLogoutDialog.value = false
                songBookViewModel.logout()
            }) { Text("Odhlásit") }
        },
        dismissButton = {
            TextButton(onClick = { showLogoutDialog.value = false }) {
                Text("Zrušit")
            }
        }
    )
}

@Composable
@OptIn(ExperimentalComposeUiApi::class)
fun SongBookListSearchTextField(songBookViewModel: SongBookViewModel, focusRequester: FocusRequester) {
    val searchValue = songBookViewModel.searchText.collectAsState()
    val keyboardController = LocalSoftwareKeyboardController.current
    BasicTextField(
        value = searchValue.value,
        onValueChange = { songBookViewModel.searchText.value = it },
        modifier = Modifier
            .fillMaxWidth()
            .focusRequester(focusRequester),
        textStyle = TextStyle.Default.copy(color = Color.White),
        cursorBrush = SolidColor(Color.White),
        maxLines = 1,
        keyboardOptions = KeyboardOptions(imeAction = ImeAction.Done),
        keyboardActions = KeyboardActions(onDone = {
            keyboardController?.hide()
            songBookViewModel.searchText.value = ""
            songBookViewModel.searching.value = false
        })
    )
}

@Composable
fun SongBookListTopBarNavigation(songBookViewModel: SongBookViewModel) {
    val isSearching = songBookViewModel.searching.collectAsState()
    if (!isSearching.value) {
        IconButton(onClick = { songBookViewModel.searching.value = true }) {
            Icon(Icons.Filled.Search, null)
        }
    }
    IconButton(onClick = { songBookViewModel.fetchSongBookList() }) {
        Icon(Icons.Filled.Refresh, null)
    }
}

@Composable
fun SongbookListLoading() {
    Column(Modifier.fillMaxSize(), Arrangement.Center, Alignment.CenterHorizontally) {
        CircularProgressIndicator(
            progress = 0.8f,
            color = Color.Magenta,
            strokeWidth = 4.dp,
        )
    }
}

@Composable
fun SongBookListError() {
    Column(Modifier.fillMaxSize(), Arrangement.Center, Alignment.CenterHorizontally) {
        Text(text = "Failed to load song book list")
    }
}

@Composable
@OptIn(ExperimentalFoundationApi::class)
fun SongBookListContent(songBookViewModel: SongBookViewModel, songViewModel: SongViewModel, navigateToSong: () -> Unit) {
    val songBookList = songBookViewModel.songBookList.collectAsState()
    val songBookHiddenList = songBookViewModel.hiddenSongBookList.collectAsState()
    val playlist = songBookViewModel.playList.collectAsState()
    val searchText = songBookViewModel.searchText.collectAsState()
    val lastBandIndex = remember { mutableStateOf(-1) }

    LazyColumn(contentPadding = PaddingValues(bottom = 16.dp)) {
        // Playlist
        stickyHeader { SongBookListHeader("Playlist", Icons.Filled.Refresh) {
            val bandIds = songBookList.value.songBookList.map { it.band.id }.distinct()
            lastBandIndex.value = (lastBandIndex.value + 1) % bandIds.size
            songBookViewModel.fetchPlaylist(bandIds[lastBandIndex.value])
        } }
        itemsIndexed(items = playlist.value.playlist.songs, itemContent = { i, sb ->
            val id = if (playlist.value.playlist.songs.getOrNull(i + 1)?.songBook?.id != sb.songBook.id) -1 else i
            if (searchText.value.isEmpty() || sb.matches(searchText.value))
                SongBookListItem(id, sb, songViewModel, navigateToSong)
        })

        // Song books
        songBookList.value.songBookList.forEach {
            stickyHeader { SongBookListHeader(it.name, if (songBookHiddenList.value.contains(it.id))
                Icons.Filled.KeyboardArrowRight else Icons.Filled.ArrowDropDown) {
                if (songBookHiddenList.value.contains(it.id))
                    songBookViewModel.hiddenSongBookList.value -= it.id
                else songBookViewModel.hiddenSongBookList.value += it.id
            } }
            if (!songBookHiddenList.value.contains(it.id)) {
                itemsIndexed(items = it.songs, itemContent = { i, sb ->
                    val id = if (it.songs.getOrNull(i + 1)?.songBook?.id != sb.songBook.id) -1 else i
                    if (searchText.value.isEmpty() || sb.matches(searchText.value))
                        SongBookListItem(id, sb, songViewModel, navigateToSong)
                })
            }
        }
    }
}

@Composable
fun SongBookListHeader(name: String, icon: ImageVector, toggleSongBook: () -> Unit) {
    Row(Modifier.fillMaxWidth().background(Color.DarkGray).padding(16.dp, 4.dp, 16.dp, 4.dp)) {
        Text(
            text = name.uppercase(),
            color = Color.White,
            fontWeight = FontWeight.Bold,
            fontSize = 16.sp,
            modifier = Modifier.clickable { toggleSongBook() }
        )
        IconButton(toggleSongBook, Modifier.size(20.dp, 20.dp).padding(top = 4.dp)) {
            Icon(icon, null)
        }
    }
}

@Composable
fun SongBookListItem(index: Int, song: Song, songViewModel: SongViewModel, navigateToSong: () -> Unit) {
    val paddingTop = if (index == 0) 4.dp else 0.dp
    val paddingBot = if (index == -1) 4.dp else 0.dp
    Card(elevation = 4.dp, modifier = Modifier.fillMaxWidth()
        .padding(start = 16.dp, end = 16.dp,
            top    = if (paddingTop <= 0.dp) 4.dp else 8.dp,
            bottom = if (paddingBot <= 0.dp) 4.dp else 8.dp
        )
        .clickable {
            songViewModel.setSong(song)
            navigateToSong()
        }
    ) {
        Row(Modifier.fillMaxWidth().padding(16.dp, 8.dp)) {
            Text("${song.name} ${song.displayId?.let { String.format("%03d", it) } ?: ""}", fontSize = 16.sp)
        }
    }
}
