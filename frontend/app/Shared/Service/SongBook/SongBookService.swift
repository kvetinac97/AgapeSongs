//
//  SongBookService.swift
//  Service
//
//  Created by Ondřej Wrzecionko on 10.03.2022.
//

import Foundation

/// Protocol for SongBook service
protocol SongBookServicing {
    /// Actual filtered song book ids
    var filteredSongBookIds: [Int] { get }
    
    /// Gets list of all song books given user has access to
    func songBookList() async -> Result<[SongBookDTO], HttpStatusError>
    
    /// Creates a new SongBook with given name in given band
    func create(songBook: SongBookEditDTO) async -> Result<SongBookDTO, HttpStatusError>
    
    /// Changes an existing SongBook with given ID
    func edit(id: Int, songBook: SongBookEditDTO) async -> Result<SongBookDTO, HttpStatusError>
    
    /// Deletes SongBook with given ID
    func delete(id: Int) async -> Result<Void, HttpStatusError>
    
    /// Saves actually filtered song book ids
    func save(filteredSongBookIds: [Int])
}

/// Helper DI protocol
protocol HasSongBookService {
    var songBookService: SongBookServicing { get }
}

struct SongBookService: SongBookServicing {
    
    // MARK: - Properties
    
    var filteredSongBookIds: [Int] {
        getFilteredSongBookIds()
    }
    
    // MARK: - Private properties
    
    private let networkService: NetworkServicing
    
    // MARK: - Init
    
    init(context: HasNetworkService) {
        networkService = context.networkService
    }
    
    // MARK: - Interface method implementation
    
    func songBookList() async -> Result<[SongBookDTO], HttpStatusError> {
        let response = await networkService.get(url: Constants.songBookListUrl)
        switch response {
        case .success(let data):
            guard let songBooks = try? JSONDecoder().decode([SongBookDTO].self, from: data) else {
                return .failure(.badtext(text: "songbook_list_response_parse_error"))
            }
            return .success(songBooks)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func create(songBook: SongBookEditDTO) async -> Result<SongBookDTO, HttpStatusError> {
        let response = await networkService.post(
            url: Constants.songBookListUrl,
            body: songBook
        )
        switch response {
        case .success(let data):
            guard let songBook = try? JSONDecoder().decode(SongBookDTO.self, from: data) else {
                return .failure(.badtext(text: "songbook_response_parse_error"))
            }
            return .success(songBook)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func edit(id: Int, songBook: SongBookEditDTO) async -> Result<SongBookDTO, HttpStatusError> {
        let response = await networkService.patch(
            url: Constants.songBookListUrl + "/" + String(id),
            body: songBook
        )
        switch response {
        case .success(let data):
            guard let songBook = try? JSONDecoder().decode(SongBookDTO.self, from: data) else {
                return .failure(.badtext(text: "songbook_response_parse_error"))
            }
            return .success(songBook)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func delete(id: Int) async -> Result<Void, HttpStatusError> {
        let response = await networkService.delete(
            url: Constants.songBookListUrl + "/" + String(id)
        )
        switch response {
        case .success(_):
            return .success(())
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func save(filteredSongBookIds: [Int]) {
        UserDefaults.standard.setValue(filteredSongBookIds, forKey: Constants.songBookFilteredIdsSavePath)
    }
    
    // MARK: - Private helpers
    
    private func getFilteredSongBookIds() -> [Int] {
        UserDefaults.standard.array(
            forKey: Constants.songBookFilteredIdsSavePath
        ) as? [Int] ?? []
    }
    
    // MARK: - Constants
    
    private enum Constants {
        static let songBookListUrl = "/songbook"
        static let songBookFilteredIdsSavePath = "filtered_songbook_ids"
    }
}

// Implementation for DI
private let _songBookService = SongBookService(context: context)

extension DI: HasSongBookService {
    var songBookService: SongBookServicing { _songBookService }
}
