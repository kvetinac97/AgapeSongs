//
//  SongService.swift
//  Service
//
//  Created by Ondřej Wrzecionko on 10.03.2022.
//

import Foundation

/// Protocol for Song service
protocol SongServicing {
    /// Actual selected song (`nil` if nothing selected)
    var selectedSong: SongSaveDTO? { get }
    
    /// Actual chord display mode (`.key` by default)
    var chordDisplayMode: ChordDisplayMode { get }
    
    /// Actual font size of application (`defaultFontSize` by default)
    var defaultFontSize: Double { get }
    
    /// Saves actual selected song
    func select(song: SongSaveDTO)
    
    /// Clear song selection
    func clearSong()
    
    /// Sets selected chord display mode
    func save(displayMode: ChordDisplayMode)
    
    /// Sets selected font size of application
    func save(fontSize: Double)
    
    /// Creates a new song with given name in given SongBook
    func create(song: SongEditDTO, note: SongNoteEditDTO?) async -> Result<SongDTO, HttpStatusError>
    
    /// Changes an existing song with given ID
    func edit(id: Int, song: SongEditDTO, note: SongNoteEditDTO?) async -> Result<SongDTO, HttpStatusError>
    
    /// Deletes song with given ID
    func delete(id: Int) async -> Result<Void, HttpStatusError>
    
    /// Finds text size for given song
    func textSize(for song: Song) -> Double
    
    /// Saves text size for given song
    func textSize(_ value: Double, for song: Song)
    
    /// Finds capo for given song
    func capo(for song: Song) -> Int
    
    /// Saves capo for given song
    func capo(_ value: Int, for song: Song)
}

/// Helper DI protocol
protocol HasSongService {
    var songService: SongServicing { get }
}

struct SongService: SongServicing {
    
    // MARK: - Properties
    
    var selectedSong: SongSaveDTO? {
        getSong()
    }
    
    var chordDisplayMode: ChordDisplayMode {
        getChordDisplayMode()
    }
    
    var defaultFontSize: Double {
        getDefaultFontSize()
    }
    
    // MARK: - Private properties
    
    private let networkService: NetworkServicing
    
    // MARK: - Init
    
    init(context: HasNetworkService) {
        networkService = context.networkService
    }
    
    // MARK: - Interface method implementation
    
    func select(song: SongSaveDTO) {
        let encoder = JSONEncoder()
        let data = try? encoder.encode(song)
        UserDefaults.standard.setValue(data, forKey: Constants.songSavePath)
    }
    
    func clearSong() {
        UserDefaults.standard.removeObject(forKey: Constants.songSavePath)
    }
    
    func save(displayMode: ChordDisplayMode) {
        UserDefaults.standard.setValue(displayMode.rawValue, forKey: Constants.chordDisplayModeSavePath)
    }
    
    func save(fontSize: Double) {
        UserDefaults.standard.setValue(fontSize, forKey: Constants.defaultFontSizeSavePath)
    }
    
    func create(song: SongEditDTO, note: SongNoteEditDTO?) async -> Result<SongDTO, HttpStatusError> {
        let response = await networkService.post(
            url: Constants.songListUrl,
            body: song
        )
        switch response {
        case .success(let data):
            guard var song = try? JSONDecoder().decode(SongDTO.self, from: data) else {
                return .failure(.badtext(text: "song_response_parse_error"))
            }
            
            // No note = success
            guard let note = note else { return .success(song) }
            
            // Try to upload note, if it fails, failure
            let noteResponse = await updateNote(songBookId: song.songBook.id, songId: song.id, note: note)
            switch noteResponse {
            case .success(let dto):
                song.note = dto
                return .success(song)
            case .failure(let error):
                return .failure(error)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func edit(id: Int, song: SongEditDTO, note: SongNoteEditDTO?) async -> Result<SongDTO, HttpStatusError> {
        let response = await networkService.patch(
            url: Constants.songListUrl + "/" + String(id),
            body: song
        )
        switch response {
        case .success(let data):
            guard var song = try? JSONDecoder().decode(SongDTO.self, from: data) else {
                return .failure(.badtext(text: "song_response_parse_error"))
            }
            
            // No note = success
            guard let note = note else { return .success(song) }
            
            // Try to upload note, if it fails, failure
            let noteResponse = await updateNote(songBookId: song.songBook.id, songId: song.id, note: note)
            switch noteResponse {
            case .success(let dto):
                song.note = dto
                return .success(song)
            case .failure(let error):
                return .failure(error)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func delete(id: Int) async -> Result<Void, HttpStatusError> {
        return await networkService.delete(
            url: Constants.songListUrl + "/" + String(id)
        ).map { _ in }
    }
    
    func textSize(for song: Song) -> Double {
        let textSize = UserDefaults.standard.double(forKey: textSizeSaveKey(for: song))
        return textSize > 0 ? textSize : Constants.defaultTextSize
    }
    
    func textSize(_ value: Double, for song: Song) {
        UserDefaults.standard.setValue(value, forKey: textSizeSaveKey(for: song))
    }
    
    func capo(for song: Song) -> Int {
        // If there is a saved capo, return it, otherwise, return default capo
        let capoSaveKey = capoSaveKey(for: song)
        if UserDefaults.standard.object(forKey: capoSaveKey) != nil {
            return UserDefaults.standard.integer(forKey: capoSaveKey)
        }
        return song.capo
    }
    
    func capo(_ value: Int, for song: Song) {
        UserDefaults.standard.setValue(value, forKey: capoSaveKey(for: song))
    }
    
    // MARK: - Private helpers
    
    private func updateNote(songBookId: Int, songId: Int, note: SongNoteEditDTO) async -> Result<SongNoteDTO, HttpStatusError> {
        let response = await networkService.put(
            url: Constants.songBookListUrl + "/" + String(songBookId) + "/songs/" + String(songId) + "/notes",
            body: note
        )
        switch response {
        case .success(let data):
            guard let note = try? JSONDecoder().decode(SongNoteDTO.self, from: data) else {
                return .failure(.badtext(text: "song_note_response_parse_error"))
            }
            return .success(note)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    private func getSong() -> SongSaveDTO? {
        guard let data = UserDefaults.standard.data(forKey: Constants.songSavePath) else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode(SongSaveDTO.self, from: data)
    }
    
    private func getChordDisplayMode() -> ChordDisplayMode {
        let value = UserDefaults.standard.integer(forKey: Constants.chordDisplayModeSavePath)
        return ChordDisplayMode(rawValue: value) ?? .key
    }
    
    private func getDefaultFontSize() -> Double {
        let value = UserDefaults.standard.double(forKey: Constants.defaultFontSizeSavePath)
        return value == 0 ? Constants.defaultFontSize : value
    }
    
    private func textSizeSaveKey(for song: Song) -> String {
        Constants.textSizeSavePath + String(song.songId)
    }
    
    private func capoSaveKey(for song: Song) -> String {
        Constants.capoSavePath + String(song.songId)
    }
    
    // MARK: - Constants
    
    private enum Constants {
        static let songListUrl = "/song"
        static let songBookListUrl = "/songbook"
        static let songSavePath = "selected_song"
        static let chordDisplayModeSavePath = "chord_display_mode"
        static let defaultFontSizeSavePath = "default_font_size"
        static let textSizeSavePath = "text_size_"
        static let capoSavePath = "capo_"
        static let defaultTextSize: Double = 25
        static let defaultFontSize: Double = 18
    }
}

// Implementation for DI
private let _songService = SongService(context: context)

extension DI: HasSongService {
    var songService: SongServicing { _songService }
}
