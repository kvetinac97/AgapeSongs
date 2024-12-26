package cz.fit.cvut.wrzecond

import android.content.Intent
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.lifecycle.ViewModelProvider
import cz.fit.cvut.wrzecond.agapesongs.ui.AgapeSongsApp
import cz.fit.cvut.wrzecond.agapesongs.viewmodel.SongBookViewModel
import cz.fit.cvut.wrzecond.agapesongs.viewmodel.SongViewModel

class MainActivity : ComponentActivity() {
    private lateinit var songBookViewModel: SongBookViewModel

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        songBookViewModel = ViewModelProvider(this)[SongBookViewModel::class.java]
        val songViewModel = ViewModelProvider(this)[SongViewModel::class.java]
        setContent { AgapeSongsApp(songBookViewModel, songViewModel) }
        handleIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIntent(intent)
    }

    private fun handleIntent(intent: Intent?) {
        val uri = intent?.data ?: return
        if (uri.scheme != "agapesongs" || uri.host != "join") return
        val secret = uri.getQueryParameter("secret") ?: return
        songBookViewModel.loginSecret.value = secret
    }
}
