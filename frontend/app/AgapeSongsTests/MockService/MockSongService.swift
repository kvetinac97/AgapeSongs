//
//  MockSongService.swift
//  AgapeSongsTests
//
//  Created by Ondřej Wrzecionko on 10.03.2022.
//

import Foundation

@testable import AgapeSongs

class MockSongService: SongServicing {
    init() {}
    
    var selectedSong: SongSaveDTO? = nil
    var chordDisplayMode: ChordDisplayMode = .key
    var defaultFontSize: Double = 18
    
    private var textSizes = [Int: Double]()
    private var capos = [Int: Int]()
    
    var createSongResponse: Result<SongDTO, HttpStatusError>?
    private(set) var createSongCalled = false
    var editSongResponse: Result<SongDTO, HttpStatusError>?
    private(set) var editSongCalled = false
    var deleteSongResponse: Result<Void, HttpStatusError>?
    private(set) var deleteSongCalled = false
    
    func select(song: SongSaveDTO) {
        selectedSong = song
    }
    
    func clearSong() {
        selectedSong = nil
    }
    
    func save(displayMode: ChordDisplayMode) {
        chordDisplayMode = displayMode
    }
    
    func save(fontSize: Double) {
        defaultFontSize = fontSize
    }
    
    func create(song: SongEditDTO, note: SongNoteEditDTO?) async -> Result<SongDTO, HttpStatusError> {
        createSongCalled = true
        return createSongResponse ?? .failure(.badtext(text: "Did not provide implementation"))
    }
    
    func edit(id: Int, song: SongEditDTO, note: SongNoteEditDTO?) async -> Result<SongDTO, HttpStatusError> {
        editSongCalled = true
        return editSongResponse ?? .failure(.badtext(text: "Did not provide implementation"))
    }
    
    func delete(id: Int) async -> Result<Void, HttpStatusError> {
        deleteSongCalled = true
        return deleteSongResponse ?? .failure(.badtext(text: "Did not provide implementation"))
    }
    
    func textSize(for song: Song) -> Double {
        textSizes[song.songId] ?? 0
    }
    
    func textSize(_ value: Double, for song: Song) {
        textSizes[song.songId] = value
    }
    
    func capo(for song: Song) -> Int {
        capos[song.songId] ?? 0
    }
    
    func capo(_ value: Int, for song: Song) {
        capos[song.songId] = value
    }
}
