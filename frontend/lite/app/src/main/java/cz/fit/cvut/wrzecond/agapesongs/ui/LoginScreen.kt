package cz.fit.cvut.wrzecond.agapesongs.ui

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import cz.fit.cvut.wrzecond.agapesongs.viewmodel.SongBookViewModel

@Composable
fun LoginScreen(songBookViewModel: SongBookViewModel) {
    AgapeSongsTheme {
        Scaffold(topBar = { LoginBar() }) { padding ->
            Column(Modifier.padding(padding)) {
                Text("Zadejte přihlašovací kód:", Modifier.padding(16.dp))
                LoginTextField(songBookViewModel)
            }
        }
    }
}

@Composable
fun LoginBar() {
    TopAppBar(
        backgroundColor = MaterialTheme.colors.primarySurface,
        elevation = 4.dp,
        title = { Text("Přihlášení") }
    )
}

@Composable
fun LoginTextField(songBookViewModel: SongBookViewModel) {
    val loginSecret = remember { mutableStateOf("") }
    TextField(
        value = loginSecret.value,
        onValueChange = { loginSecret.value = it },
        keyboardOptions = KeyboardOptions(
            keyboardType = KeyboardType.Password,
            imeAction = ImeAction.Done
        ),
        keyboardActions = KeyboardActions(onDone = {
            songBookViewModel.loginSecret.value = loginSecret.value.split("\n").first()
        }),
        singleLine = true,
        modifier = Modifier
            .fillMaxWidth(0.9F)
            .padding(horizontal = 16.dp)
    )
}
