//
//  SongEditViewModel.swift
//  ViewModel
//
//  Created by Ondřej Wrzecionko on 30.03.2022.
//

import Foundation

final class SongEditViewModel: ObservableObject {
    
    // MARK: - Form properties
    
    @Published var name: String = ""
    @Published var displayId: String = ""
    @Published var songBookId: Int = 0
    @Published var key: SongKey = .C
    @Published var bpm: String = ""
    @Published var beat: SongBeat = .FOUR_FOURTHS
    @Published var capo: String = ""
    @Published var text: String = NSLocalizedString("song_create_default_text", comment: "")
    @Published var note: String = ""
        
    @Published var editSong: Song? = nil
    @Published var state: EditState = .idle
    
    var editing: Bool {
        editSong != nil
    }
    
    // MARK: - Private properties
    
    private let songBookListViewModel: SongBookListViewModel
    private let appState: AppState
    private let songService: SongServicing
    
    // MARK: - Init
    
    init(
        context: HasAppState & HasSongService,
        songBookListViewModel: SongBookListViewModel,
        song: Song? = nil
    ) {
        self.appState = context.appState
        self.songService = context.songService
        self.songBookListViewModel = songBookListViewModel
        
        if let song = song {
            editSong = song
            name = song.name
            songBookId = song.songBook.id
            key = song.key
            bpm = String(song.bpm)
            beat = song.beat
            capo = String(song.capo)
            text = song.text.reduce("") { text, line -> String in
                if let chords = line.chords {
                    return (text.isEmpty ? "." : text + "\n.") + chords + "\n " + line.text
                }
                return (text.isEmpty ? " " : text + "\n ") + line.text
            }
            
            if let displayId = song.displayId {
                self.displayId = String(displayId)
            }
            
            if let note = song.note {
                self.note = note.notes
            }
        }
        else {
            songBookId = appState.songBook?.id ?? 0
        }
    }
    
    // MARK: - Validation
    
    /// Simple function to check for input validity
    func isValid() -> Bool {
        !name.isEmpty && (displayId.isEmpty || Int(displayId) != nil)
            && songBookId != 0 && !text.isEmpty
    }
    
    // MARK: - Public methods
    
    func createOrEditSong() {
        if !isValid() {
            return
        }
        
        state = .submitting
        Task {
            await createOrEditSong()
        }
    }
    
    func createOrEditSong() async {
        let dto = createEditDTO()
        let note = createEditNoteDTO()
        let result: Result<SongDTO, HttpStatusError>
        if let editSong = editSong {
            result = await songService.edit(id: editSong.songId, song: dto, note: note)
        }
        else {
            result = await songService.create(song: dto, note: note)
        }
        await createOrEdit(editSong: editSong, result: result)
    }
    
    func saveOffline() {
        // Create cache DTO
        let offlineSong = SongCacheDTO(
            song: createEditDTO(offline: true),
            note: createEditNoteDTO(),
            operation: editSong == nil ? .create : .edit,
            // When creating song, use special id (< 0)
            id: editSong?.songId ?? -(songBookListViewModel.editedSongs.count + 1)
        )
        
        // Edit existing offline song edit
        if let index = songBookListViewModel.editedSongs.firstIndex(where: { $0.id == offlineSong.id }) {
            let originalOperation = songBookListViewModel.editedSongs[index].operation
            
            // Keep create / edit operation
            songBookListViewModel.editedSongs[index] = SongCacheDTO(
                song: offlineSong.song,
                note: offlineSong.note,
                operation: originalOperation,
                id: offlineSong.id
            )
        }
        // Add as new
        else {
            songBookListViewModel.editedSongs.append(offlineSong)
        }
        
        // Force reload
        songBookListViewModel.loadSongBooks()
    }
    
    // MARK: - Private methods
    
    private func createEditDTO(offline: Bool = false) -> SongEditDTO {
        SongEditDTO(
            name: name,
            // Forbid changing song books in offline edits
            songBookId: offline ? (editSong?.removeFromPlaylist().songBook.id ?? songBookId) : songBookId,
            key: key,
            bpm: Int(bpm) ?? (editSong?.bpm ?? 999),
            beat: beat,
            capo: Int(capo) ?? (editSong?.capo ?? 0),
            text: text,
            displayId: Int(displayId)
        )
    }
    
    private func createEditNoteDTO() -> SongNoteEditDTO? {
        editSong?.note != nil || !note.isEmpty
            ? SongNoteEditDTO(notes: note, capo: 0)
            : nil
    }
    
    @MainActor
    private func createOrEdit(editSong: Song?, result: Result<SongDTO, HttpStatusError>) async {
        switch result {
        case .success(let dto):
            let song = dto.domain
            // Find existing song and replace it
            if let editSong = editSong?.removeFromPlaylist() {
                editSongSuccess(oldSong: editSong, newSong: song)
            }
            // Just insert a new song
            else {
                createSongSuccess(song: song)
            }
            
            // Update song on Mac
            if appState.song?.id == song.id {
                appState.song = song
            }
            
            // Update playlist song on Mac
            if appState.song?.inPlaylist == true && appState.song?.songId == song.songId {
                appState.song = song.addToPlaylist()
            }
            state = .success
        case .failure(let error):
            print(error)
            state = .failure(error.errorDescription)
        }
    }
    
    /// Called when we should perform song edit
    private func editSongSuccess(oldSong: Song, newSong: Song) {
        // Find old and new indexes
        guard let oldIndex = songBookListViewModel.songBooks.firstIndex(where: {
            $0.id == oldSong.songBook.id
        }), let oldSongIndex = songBookListViewModel.songBooks[oldIndex].songs.firstIndex(where: {
            $0.id == oldSong.id
        }) else { return }
        
        // Same SongBook, just replace
        if oldSong.songBook.id == newSong.songBook.id {
            songBookListViewModel.songBooks[oldIndex].songs[oldSongIndex] = newSong
            if oldSong.songBook.id == appState.songBook?.id {
                appState.songBook = songBookListViewModel.songBooks[oldIndex]
            }
        }
        // Different SongBook = remove from old and put to new
        else {
            songBookListViewModel.songBooks[oldIndex].songs.removeAll(where: {
                $0.songId == oldSong.songId
            })
            if oldSong.songBook.id == appState.songBook?.id {
                appState.songBook = songBookListViewModel.songBooks[oldIndex]
            }
            
            // Find new SongBook and insert song here
            if let newIndex = songBookListViewModel.songBooks.firstIndex(where: {
                $0.id == newSong.songBook.id
            }) {
                songBookListViewModel.songBooks[newIndex].songs.append(newSong)
                if newSong.songBook.id == appState.songBook?.id {
                    appState.songBook = songBookListViewModel.songBooks[newIndex]
                }
            }
        }
        
        // Correct songsById and playlist
        songBookListViewModel.songsById[oldSong.idString] = newSong
        if let playlistIndex = appState.playlist.songs.firstIndex(where: {
            $0.songId == oldSong.songId
        }) {
            appState.playlist.songs[playlistIndex] = newSong.addToPlaylist()
            songBookListViewModel.songsById[oldSong.addToPlaylist().idString] = newSong.addToPlaylist()
        }
    }
    
    /// Called when new song was successfully created
    private func createSongSuccess(song: Song) {
        // Find new index
        guard let index = songBookListViewModel.songBooks.firstIndex(where: {
            $0.id == song.songBook.id
        }) else { return }
        
        // Insert new song
        songBookListViewModel.songBooks[index].songs.append(song)
        if song.songBook.id == appState.songBook?.id {
            appState.songBook = songBookListViewModel.songBooks[index]
        }
        
        // Add to songsById
        songBookListViewModel.songsById[song.idString] = song
    }
}
