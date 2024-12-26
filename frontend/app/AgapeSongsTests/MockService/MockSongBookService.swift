//
//  MockSongBookService.swift
//  AgapeSongsTests
//
//  Created by Ondřej Wrzecionko on 12.03.2022.
//

import Foundation

@testable import AgapeSongs

class MockSongBookService: SongBookServicing {
    init() {}
    
    var filteredSongBookIds = [Int]()
    var songBookListResponse: Result<[SongBookDTO], HttpStatusError>?
    private(set) var songBookListCalled = false
    
    var createSongBookResponse: Result<SongBookDTO, HttpStatusError>?
    private(set) var createSongBookCalled = false
    var editSongBookResponse: Result<SongBookDTO, HttpStatusError>?
    private(set) var editSongBookCalled = false
    var deleteSongBookResponse: Result<Void, HttpStatusError>?
    private(set) var deleteSongBookCalled = false
    
    func songBookList() async -> Result<[SongBookDTO], HttpStatusError> {
        songBookListCalled = true
        return songBookListResponse ?? .failure(.badtext(text: "Did not provide implementation"))
    }
    
    func create(songBook: SongBookEditDTO) async -> Result<SongBookDTO, HttpStatusError> {
        createSongBookCalled = true
        return createSongBookResponse ?? .failure(.badtext(text: "Did not provide implementation"))
    }
    
    func edit(id: Int, songBook: SongBookEditDTO) async -> Result<SongBookDTO, HttpStatusError> {
        editSongBookCalled = true
        return editSongBookResponse ?? .failure(.badtext(text: "Did not provide implementation"))
    }
    
    func delete(id: Int) async -> Result<Void, HttpStatusError> {
        deleteSongBookCalled = true
        return deleteSongBookResponse ?? .failure(.badtext(text: "Did not provide implementation"))
    }
    
    func save(filteredSongBookIds: [Int]) {
        self.filteredSongBookIds = filteredSongBookIds
    }
}
