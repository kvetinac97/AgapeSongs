//
//  PlaylistService.swift
//  Service
//
//  Created by Ondřej Wrzecionko on 31.03.2022.
//

import Foundation

/// Protocol for Playlist service
protocol PlaylistServicing {
    /// Actual saved playlist
    var playlist: PlaylistSaveDTO { get }
    
    /// Actual saved default band id
    var defaultBandId: Int? { get }
    
    /// Saves current playlist
    func save(playlist: PlaylistSaveDTO, upload: Bool)
    
    /// Saves default band ID
    func save(defaultBandId: Int?)
    
    /// Loads given band playlist from API
    func getPlaylist(bandId: Int) async -> Result<PlaylistDTO, HttpStatusError>
    
    /// Saves given band playlist to API
    func save(bandId: Int, playlist: PlaylistDTO) async -> Result<PlaylistDTO, HttpStatusError>
}

/// Helper DI protocol
protocol HasPlaylistService {
    var playlistService: PlaylistServicing { get }
}

struct PlaylistService: PlaylistServicing {
    
    // MARK: - Properties
    
    var playlist: PlaylistSaveDTO {
        getPlaylist()
    }
    
    var defaultBandId: Int? {
        getDefaultBandId()
    }
    
    // MARK: - Private properties
    
    private let networkService: NetworkServicing
    
    // MARK: - Init
    
    init(context: HasNetworkService) {
        networkService = context.networkService
    }
    
    // MARK: - Interface method implementation
    
    func getPlaylist(bandId: Int) async -> Result<PlaylistDTO, HttpStatusError> {
        let response = await networkService.get(
            url: Constants.bandListUrl + "/" + String(bandId) + "/playlist",
            cache: false
        )
        return handleResponse(response: response)
    }
    
    func save(bandId: Int, playlist: PlaylistDTO) async -> Result<PlaylistDTO, HttpStatusError> {
        let response = await networkService.put(
            url: Constants.bandListUrl + "/" + String(bandId) + "/playlist",
            body: playlist
        )
        return handleResponse(response: response)
    }
    
    // MARK: - Private helpers
    
    func handleResponse(response: Result<Data, HttpStatusError>) -> Result<PlaylistDTO, HttpStatusError> {
        switch response {
        case .success(let data):
            guard let playlist = try? JSONDecoder().decode(PlaylistDTO.self, from: data) else {
                return .failure(.badtext(text: "playlist_response_parse_error"))
            }
            return .success(playlist)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    private func getPlaylist() -> PlaylistSaveDTO {
        let emptyPlaylist = PlaylistSaveDTO(songs: [])
        guard let data = UserDefaults.standard.data(
            forKey: Constants.playlistSavePath
        ) else { return emptyPlaylist }
        
        let decoder = JSONDecoder()
        let playlist = try? decoder.decode(PlaylistSaveDTO.self, from: data)
        return playlist ?? emptyPlaylist
    }
    
    private func getDefaultBandId() -> Int? {
        let defaultBandId = UserDefaults.standard.integer(forKey: Constants.defaultBandIdSavePath)
        return defaultBandId == 0 ? nil : defaultBandId
    }
    
    func save(playlist: PlaylistSaveDTO, upload: Bool) {
        let encoder = JSONEncoder()
        let data = try? encoder.encode(playlist)
        UserDefaults.standard.setValue(data, forKey: Constants.playlistSavePath)
        
        if let bandId = defaultBandId, upload {
            Task {
                let dto = PlaylistDTO(songs: playlist.songs.map { $0.id })
                let result = await save(bandId: bandId, playlist: dto)
                switch result {
                case .success(_): print("✅ Playlist (\(bandId)) auto-saved successfully.")
                case .failure(let error): print("❌ Playlist (\(bandId)) auto-save failed. \(error.errorDescription)")
                }
            }
        }
    }
    
    func save(defaultBandId: Int?) {
        UserDefaults.standard.setValue(defaultBandId, forKey: Constants.defaultBandIdSavePath)
    }
    
    // MARK: - Constants
    
    private enum Constants {
        static let bandListUrl = "/band"
        static let playlistSavePath = "current_playlist"
        static let defaultBandIdSavePath = "default_band_id"
    }
}

// Implementation for DI
private let _playlistService = PlaylistService(context: context)

extension DI: HasPlaylistService {
    var playlistService: PlaylistServicing { _playlistService }
}
