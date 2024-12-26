//
//  MockPlaylistService.swift
//  AgapeSongsTests
//
//  Created by Ondřej Wrzecionko on 31.03.2022.
//

import Foundation

@testable import AgapeSongs

class MockPlaylistService: PlaylistServicing {
    init() {}
    
    var playlist = PlaylistSaveDTO(songs: [])
    var defaultBandId: Int? = nil
    
    var playlistResponse: Result<PlaylistDTO, HttpStatusError>?
    private(set) var getPlaylistCalled = false
    
    var savePlaylistResponse: Result<PlaylistDTO, HttpStatusError>?
    private(set) var savePlaylistCalled = false

    func save(playlist: PlaylistSaveDTO, upload: Bool) {
        self.playlist = playlist
    }
    
    func save(defaultBandId: Int?) {
        self.defaultBandId = defaultBandId
    }
    
    func getPlaylist(bandId: Int) async -> Result<PlaylistDTO, HttpStatusError> {
        getPlaylistCalled = true
        return playlistResponse ?? .failure(.badtext(text: "Did not provide implementation"))
    }
    
    func save(bandId: Int, playlist: PlaylistDTO) async -> Result<PlaylistDTO, HttpStatusError> {
        savePlaylistCalled = true
        return playlistResponse ?? .failure(.badtext(text: "Did not provide implementation"))
    }
}
