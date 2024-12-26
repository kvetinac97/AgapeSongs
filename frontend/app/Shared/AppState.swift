//
//  AppState.swift
//  AgapeSongs
//
//  Created by Ondřej Wrzecionko on 09.03.2022.
//

import Foundation

/// Helper DI protocol
protocol HasAppState {
    var appState: AppState { get }
}

/// Class holding the current application state
/// Accessible from all Views and ViewModels
class AppState: ObservableObject {
    
    // MARK: - Public properties
    
    /// Currently logged user (`nil` if logged out)
    @Published private(set) var user: UserLogin?
    
    /// Currently selected band (`nil` if no band is selected)
    @Published var band: Band? {
        didSet {
            if let band = band {
                bandService.select(band: band.dto)
            }
            else {
                bandService.clearBand()
            }
        }
    }
    
    /// Currently selected song (`nil` if no song is selected)
    @Published var song: Song? {
        didSet {
            if let song = song {
                songService.select(song: song.dto)
            }
            else {
                songService.clearSong()
            }
        }
    }
    
    /// Edit mode
    @Published var editMode: Bool = false
    
    /// SongBook list - currently searched song
    @Published var songBookSearch: String = ""
    
    /// SongBook list - hidden song book ids
    @Published var songBookFilter = [Int]() {
        didSet {
            songBookService.save(filteredSongBookIds: songBookFilter)
        }
    }
    
    /// Current playlist
    @Published var playlist: Playlist {
        didSet {
            playlistService.save(playlist: playlist.dto, upload: playlistUpload)
        }
    }
    @Published var playlistUpload: Bool = true
    
    // MARK: - Navigation properties (macOS)
    
    /// Settings navigation
    @Published var settings: Bool = false
    
    /// SongBook navigation
    @Published var songBook: SongBook? = nil
    
    /// Special selected song property
    @Published var selectedSongId: String? = nil
    
    // MARK: - Navigation (SongBook)

    @Published var editSongBook: EditModel<SongBook>? = nil
    
    @Published var isSongBookDeleteDisplayed: Bool = false
    @Published var deleteSongBook: SongBook? = nil {
        didSet {
            isSongBookDeleteDisplayed = deleteSongBook != nil
        }
    }
    
    // MARK: - Navigation (Song)
    
    @Published var editSong: EditModel<Song>? = nil
    
    @Published var isSongDeleteDisplayed: Bool = false
    @Published var deleteSong: Song? = nil {
        didSet {
            isSongDeleteDisplayed = deleteSong != nil
        }
    }
    
    // MARK: - General settings
    
    /// Current chord display mode
    @Published var chordDisplayMode: ChordDisplayMode {
        didSet {
            songService.save(displayMode: chordDisplayMode)
        }
    }
    
    /// Current band to which playlist changes will be saved automatically
    @Published var defaultBandId: Int? {
        didSet {
            playlistService.save(defaultBandId: defaultBandId)
        }
    }
    
    /// Current font size used for texts in application
    @Published var defaultFontSize: Double {
        didSet {
            songService.save(fontSize: defaultFontSize)
        }
    }
    
    /// Current floating mode of app window (macOS)
    @Published var isWindowFloating: Bool = false
    
    // MARK: - Private properties
    
    private let authService: AuthServicing
    private let bandService: BandServicing
    private let songService: SongServicing
    private let songBookService: SongBookServicing
    private let playlistService: PlaylistServicing
    
    // MARK: - Init
    
    init(context: HasAuthService & HasBandService & HasSongService &
            HasSongBookService & HasPlaylistService) {
        authService = context.authService
        bandService = context.bandService
        songService = context.songService
        songBookService = context.songBookService
        playlistService = context.playlistService
        
        user = authService.user?.domain
        band = bandService.selectedBand?.domain
        song = songService.selectedSong?.domain
        songBookFilter = songBookService.filteredSongBookIds
        playlist = playlistService.playlist.domain
        
        chordDisplayMode = songService.chordDisplayMode
        defaultBandId = playlistService.defaultBandId
        defaultFontSize = songService.defaultFontSize
    }
    
    // MARK: - Public methods
    
    func login(user: UserLogin) {
        authService.login(user: user.dto)
        self.user = user
    }
    func logout() {
        authService.logout()
        self.user = nil
        self.song = nil
        self.songBook = nil
        self.band = nil
        self.settings = false
    }
    
    // MARK: - Constants
    
    private enum Constants {
        static let playlistId = -1
    }
}
