//
//  SongBookListViewModel.swift
//  ViewModel
//
//  Created by Ondřej Wrzecionko on 10.03.2022.
//

import Foundation
import SwiftUI

final class SongBookListViewModel: ObservableObject {
    
    // MARK: - Public properties (Songs)
    
    @Published var state: SongBookListLoadState = .loading
    @Published var songBooks = [SongBook]()
    
    @Published var songsById = [String: Song]()
    @Published var selectedSongId: String? = nil {
        didSet {
            if let selectedSongIdSeparated = selectedSongId?.components(separatedBy: ","),
                let songId = selectedSongIdSeparated.first {
                let song = songsById[songId]
                appState.song = selectedSongIdSeparated.count > 1 ? song?.addToPlaylist() : song
                appState.selectedSongId = selectedSongId
            }
        }
    }
    
    @Published var isDeleteSongBookDone: Bool = false
    @Published var deleteSongBookError: String = ""
    
    @Published var isDeleteSongDone: Bool = false
    @Published var deleteSongError: String = ""
    
    @Published var isJoinBandDone: Bool = false
    @Published var joinBandError: String = ""
    
    @Published var editedSongs: [SongCacheDTO] {
        didSet {
            guard let data = try? JSONEncoder().encode(editedSongs) else {
                return
            }
            UserDefaults.standard.set(data, forKey: Constants.editedSongsPath)
        }
    }
    
    // MARK: - Public properties (Playlist)
    
    @Published var playlistBands = [Band]()
    @Published var isPlaylistAlertDisplayed: Bool = false
    @Published var playlistAlertText: String = "" {
        didSet {
            isPlaylistAlertDisplayed = !playlistAlertText.isEmpty
        }
    }
    
    @Published var isSelectPlaylistEditDisplayed: Bool = false
    @Published var isPlaylistEditLoading: Bool = false
    
    @Published var isSelectPlaylistViewDisplayed: Bool = false
    @Published var isPlaylistViewLoading: Bool = false
    
    @Published var isDeletePlaylistViewDisplayed: Bool = false

    // MARK: - Private properties
    
    private let appState: AppState
    private let bandService: BandServicing
    private let playlistService: PlaylistServicing
    private let songBookService: SongBookServicing
    private let songService: SongServicing
    
    // MARK: - Init
    
    init(context: HasAppState & HasBandService & HasPlaylistService & HasSongBookService & HasSongService) {
        appState = context.appState
        bandService = context.bandService
        playlistService = context.playlistService
        songBookService = context.songBookService
        songService = context.songService
        
        let data = UserDefaults.standard.data(forKey: Constants.editedSongsPath) ?? Data()
        editedSongs = (try? JSONDecoder().decode([SongCacheDTO].self, from: data)) ?? []
    }
    
    // MARK: - Public methods (Band joining)
    
    func openURL(url: URL) {
        guard let components = URLComponents(
            url: url, resolvingAgainstBaseURL: false
        ),  let bandIdPath = components.path.split(separator: "/").last,
            let bandId = Int(bandIdPath),
            let queryItems = components.queryItems,
            let secret = queryItems.first(where: {
                $0.name == "secret"
            })?.value else { return }
        
        if url.scheme != "agapesongs" {
            return
        }
        
        Task { await joinBand(joinDto: BandJoinDTO(id: bandId, secret: secret)) }
    }
    
    // MARK: - Public methods (Song)
    
    func delete(songBook: SongBook) {
        Task { await delete(songBook: songBook) }
    }
    
    func delete(songBook: SongBook) async {
        let result = await songBookService.delete(id: songBook.id)
        await delete(songBook: songBook, result: result)
    }
        
    func delete(song: Song) {
        Task { await delete(song: song) }
    }
    
    func delete(song: Song) async {
        let result = await songService.delete(id: song.songId)
        await delete(song: song, result: result)
    }
    
    func loadSongBooks() {
        state = .loading
        Task { await loadSongBooks() }
    }
    
    func loadSongBooks() async {
        // There are some cached edits – we have to submit them first
        if !editedSongs.isEmpty {
            await saveEditedSongs()
            
            // Cancel loading – error whilst submitting
            if case .failure(_) = state {
                return
            }
        }
        
        let songBooks = await songBookService.songBookList()
        await loadSongBooks(result: songBooks)
    }
    
    // MARK: - Public methods (Playlist)
    
    func savePlaylist() {
        // Get correct bands
        let leaderBands = playlistBands.filter { $0.canEdit(user: appState.user) }
        
        // No bands
        if leaderBands.isEmpty {
            playlistAlertText = NSLocalizedString("playlist_upload_not_leader", comment: "")
        }
        // Only one band, select it
        else if leaderBands.count == 1, let first = leaderBands.first {
            savePlaylist(bandId: first.id)
        }
        // There is something to select
        else { isSelectPlaylistEditDisplayed = true }
    }
    
    func savePlaylist(bandId: Int) {
        isPlaylistEditLoading = true
        Task { await savePlaylist(bandId: bandId) }
    }
    
    func savePlaylist(bandId: Int) async {
        let dto = PlaylistDTO(songs: appState.playlist.songs.map { $0.songId })
        let playlist = await playlistService.save(bandId: bandId, playlist: dto)
        await loadPlaylist(result: playlist)
    }
    
    func loadPlaylist() {
        // No bands
        if playlistBands.isEmpty {
            playlistAlertText = NSLocalizedString("playlist_download_not_leader", comment: "")
        }
        // Only one band, select it
        else if playlistBands.count == 1, let first = playlistBands.first {
            loadPlaylist(bandId: first.id)
        }
        // There is something to select
        else { isSelectPlaylistViewDisplayed = true }
    }
    
    func loadPlaylist(bandId: Int) {
        isPlaylistViewLoading = true
        Task { await loadPlaylist(bandId: bandId) }
    }
    
    func loadPlaylist(bandId: Int) async {
        let playlist = await playlistService.getPlaylist(bandId: bandId)
        await loadPlaylist(result: playlist)
    }
    
    // MARK: - Private methods (Band)
    
    private func joinBand(joinDto: BandJoinDTO) async {
        let result = await bandService.join(band: joinDto)
        await joinBand(result: result)
    }
    
    @MainActor
    private func joinBand(result: Result<BandDTO, HttpStatusError>) async {
        switch result {
        case .success(_):
            joinBandError = ""
            Task { await loadSongBooks() }
        case .failure(let error):
            print(error)
            joinBandError = String(error.errorDescription)
        }
        isJoinBandDone = true
    }
    
    // MARK: - Private methods (Songs)
    
    private func saveEditedSongs() async {
        var failedToSaveNetwork = [SongCacheDTO]()
        var failedToSavePreconditions = [SongCacheDTO]()
        
        for editedSong in editedSongs {
            let result: Result<SongDTO, HttpStatusError>
            switch editedSong.operation {
            case .create:
                result = await songService.create(song: editedSong.song, note: editedSong.note)
            case .edit:
                result = await songService.edit(id: editedSong.id, song: editedSong.song, note: editedSong.note)
            }
            
            if case .failure(let error) = result {
                switch error {
                // Retry on the next load
                case .network:
                    failedToSaveNetwork.append(editedSong)
                // Some preconditions failed – cannot save
                default:
                    failedToSavePreconditions.append(editedSong)
                }
            }
        }
        
        await saveEditedSongs(
            failedNetwork: failedToSaveNetwork,
            failedPrecondition: failedToSavePreconditions
        )
    }
    
    @MainActor
    private func saveEditedSongs(failedNetwork: [SongCacheDTO], failedPrecondition: [SongCacheDTO]) {
        editedSongs = failedNetwork // Replace offline songs
        
        // Show error message for failed preconditions
        if !failedPrecondition.isEmpty {
            let errorMessage = NSLocalizedString("could_not_save_songs", comment: "") + failedPrecondition.map { $0.song.name }.joined(separator: ", ")
            state = .failure(errorMessage)
        }
    }
    
    /// Helper function to add offline edited songs to song books
    private func editedSongBooks(songBooks: [SongBookDTO]) -> [SongBookDTO] {
        var songBooks = songBooks
        editedSongs.forEach { editedSong in
            // Try to find the song book to add song to
            guard let songBookIndex = songBooks.firstIndex(where: { $0.id == editedSong.song.songBookId }) else {
                return
            }
            let sb = songBooks[songBookIndex]
            let songBookRaw = SongBookRawDTO(id: sb.id, name: sb.name, band: sb.band)
            let dto = editedSong.songDTO(songBook: songBookRaw)
            
            switch editedSong.operation {
            case .create:
                songBooks[songBookIndex] = SongBookDTO(
                    id: sb.id,
                    band: sb.band,
                    name: sb.name,
                    songs: sb.songs + [dto] // Add song to song book
                )
            case .edit:
                var songs = sb.songs
                guard let songIndex = songs.firstIndex(where: { $0.id == editedSong.id }) else {
                    return
                }
                songs[songIndex] = dto // Update song in song book
                songBooks[songBookIndex] = SongBookDTO(
                    id: sb.id,
                    band: sb.band,
                    name: sb.name,
                    songs: songs
                )
            }
        }
        return songBooks
    }
    
    @MainActor
    private func loadSongBooks(result: Result<[SongBookDTO], HttpStatusError>) async {
        let hiddenBandIds = bandService.getHiddenBandIds()
        switch result {
        case .success(let responseSongBooks):
            let songBooks = editedSongBooks(songBooks: responseSongBooks)
            self.songBooks = songBooks.map { $0.domain }.filter {
                // hide songbooks from hidden bands
                !hiddenBandIds.contains($0.band.id)
            }
            songsById = [:]
            songsById = self.songBooks.flatMap { $0.songs }.reduce(into: songsById) {
                $0[$1.idString] = $1
            }
            playlistBands = Array(Set(self.songBooks.map { $0.band })).filter {
                !hiddenBandIds.contains($0.id) // hide bands
            }.sorted {
                $0.name.localizedCompare($1.name) == .orderedAscending
            }
            
            appState.songBook = self.songBooks.first(where: { $0.id == appState.songBook?.id })
            state = .success
        case .failure(let error):
            print(error)
            
            // Unauthorized, log out
            if case .badcode(let code) = error, code == 401 {
                appState.logout()
                return
            }
            
            state = .failure(error.errorDescription)
        }
    }
    
    @MainActor
    private func delete(songBook: SongBook, result: Result<Void, HttpStatusError>) async {
        switch result {
        case .success(_):
            // Remove SongBook from list
            songBooks.removeAll(where: { $0.id == songBook.id })
            // Remove all songs from songsById, playlist and unselect if they were playlist
            songBook.songs.forEach { removeFromData(song: $0) }
            // If deleted SongBook was selected, unselect it
            if songBook.id == appState.songBook?.id {
                appState.songBook = nil
            }
            deleteSongBookError = ""
        case .failure(let error):
            print(error)
            deleteSongBookError = String(error.errorDescription)
        }
        isDeleteSongBookDone = true
    }
    
    @MainActor
    private func delete(song: Song, result: Result<Void, HttpStatusError>) async {
        switch result {
        case .success(_):
            // Delete song from its SongBook
            if let index = songBooks.firstIndex(where: { $0.id == song.songBook.id }) {
                songBooks[index].songs.removeAll(where: { $0.id == song.id })
                if songBooks[index].id == appState.songBook?.id {
                    appState.songBook = songBooks[index]
                }
            }
            removeFromData(song: song)
            deleteSongError = ""
        case .failure(let error):
            print(error)
            deleteSongError = String(error.errorDescription)
        }
        isDeleteSongDone = true
    }
    
    /// Delete given `song` from playlist, songsById and unselect it
    private func removeFromData(song: Song) {
        // Delete song from Playlist
        appState.playlist.songs.removeAll(where: { $0.songId == song.songId })
        
        // Delete song from songsByID
        songsById.removeValue(forKey: song.idString)
        songsById.removeValue(forKey: song.addToPlaylist().idString)
        
        // Unselect song if it was selected
        if song.songId == appState.song?.songId {
            appState.song = nil
        }
    }
    
    // MARK: - Private methods (Playlist)
    
    @MainActor
    private func loadPlaylist(result: Result<PlaylistDTO, HttpStatusError>) async {
        switch result {
        case .success(let playlistDto):
            // Firstly, remove all old playlist songs from songsByID
            appState.playlist.songs.forEach { songsById.removeValue(forKey: $0.idString) }
            // Secondly, set new songs based from API playlist response
            appState.playlistUpload = false
            appState.playlist.songs = playlistDto.songs.compactMap { songId in
                songsById.first(where: { $0.value.songId == songId })?.value.addToPlaylist()
            }
            appState.playlistUpload = true
            // Lastly, insert all new playlist songs to songsByID
            appState.playlist.songs.forEach { songsById[$0.idString] = $0 }
            
            // Display success dialog
            playlistAlertText = NSLocalizedString(isPlaylistEditLoading ? "playlist_upload_success" : "playlist_download_success", comment: "")
        case .failure(let error):
            playlistAlertText = NSLocalizedString(isPlaylistEditLoading ? "playlist_upload_failure" : "playlist_download_failure", comment: "") + error.errorDescription
        }
    }
    
    enum Constants {
        static let editedSongsPath = "offline_edit"
    }
}
