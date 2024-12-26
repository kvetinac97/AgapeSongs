//
//  SongBookEditViewModelTests.swift
//  AgapeSongsTests
//
//  Created by Ondřej Wrzecionko on 06.04.2022.
//

import Foundation
import XCTest

@testable import AgapeSongs

final class SongBookEditViewModelTests: AgapeSongsTestCase {
    
    private struct DI: HasAppState & HasPlaylistService & HasSongBookService & HasSongService {
        let appState: AppState
        let playlistService: PlaylistServicing
        let songBookService: SongBookServicing
        let songService: SongServicing
    }
    
    private var songBookListViewModel: SongBookListViewModel!
    private var viewModel: SongBookEditViewModel!
    
    private let dummySongBook = SongBookDTO(
        id: 1, band: BandDTO(id: 1, name: "", secret: "", members: []),
        name: "",
        songs: []
    )
    
    override func setUp() {
        super.setUp()
        setUpViewModel()
    }
    
    // MARK: - Tests
    
    func testCreateSongBookSuccess() async {
        songBookService.createSongBookResponse = .success(dummySongBook)
        songBookListViewModel.songBooks = []
        
        await viewModel.createOrEditSongBook()
                
        XCTAssertEqual(viewModel.state, .success)
        XCTAssertEqual(songBookListViewModel.songBooks, [dummySongBook.domain])
    }
    
    func testCreateSongBookFailure() async {
        songBookService.createSongBookResponse = .failure(.badtext(text: "Mock error"))
        songBookListViewModel.songBooks = [dummySongBook.domain]

        await viewModel.createOrEditSongBook()

        XCTAssertEqual(viewModel.state, .failure("Mock error"))
        XCTAssertEqual(songBookListViewModel.songBooks, [dummySongBook.domain])
    }

    func testEditSongBookSuccess() async {
        let dummySongBook2 = SongBookDTO(id: dummySongBook.id, band: dummySongBook.band, name: "Another", songs: dummySongBook.songs)
        songBookService.editSongBookResponse = .success(dummySongBook2)

        let songBook = dummySongBook.domain, songBook2 = dummySongBook2.domain
        songBookListViewModel.songBooks = [songBook]
        appState.songBook = songBook

        viewModel.editSongBook = songBook

        await viewModel.createOrEditSongBook()

        XCTAssertEqual(viewModel.state, .success)
        XCTAssertEqual(songBookListViewModel.songBooks, [songBook2])
        XCTAssertEqual(appState.songBook, songBook2)
    }

    func testEditSongBookFailure() async {
        songBookService.editSongBookResponse = .failure(.badtext(text: "Mock error"))

        let songBook = dummySongBook.domain
        viewModel.editSongBook = songBook
        songBookListViewModel.songBooks = [songBook]

        await viewModel.createOrEditSongBook()

        XCTAssertEqual(viewModel.state, .failure("Mock error"))
        XCTAssertEqual(songBookListViewModel.songBooks, [songBook])
    }
    
    // MARK: - Private helpers
    
    private func setUpViewModel() {
        let context = DI(
            appState: appState,
            playlistService: playlistService,
            songBookService: songBookService,
            songService: songService
        )
        songBookListViewModel = SongBookListViewModel(context: context)
        viewModel = SongBookEditViewModel(
            context: context,
            songBookListViewModel: songBookListViewModel
        )
    }
}
