//
//  SongBookEditViewModel.swift
//  ViewModel
//
//  Created by Ondřej Wrzecionko on 28.03.2022.
//

import SwiftUI

final class SongBookEditViewModel: ObservableObject {
    
    // MARK: - Form properties
    
    @Published var name: String = ""
    @Published var bandId: Int = 0
    
    @Published var editSongBook: SongBook? = nil
    @Published var state: EditState = .idle
    
    var editing: Bool {
        editSongBook != nil
    }
    
    // MARK: - Private properties
    
    private let appState: AppState
    private let songBookService: SongBookServicing
    private let songBookListViewModel: SongBookListViewModel
    
    // MARK: - Init
    
    init(
        context: HasAppState & HasSongBookService,
        songBookListViewModel: SongBookListViewModel,
        songBook: SongBook? = nil
    ) {
        self.appState = context.appState
        self.songBookService = context.songBookService
        self.songBookListViewModel = songBookListViewModel
        
        if let songBook = songBook {
            editSongBook = songBook
            name = songBook.name
            bandId = songBook.band.id
        }
    }
    
    // MARK: - Validation
    
    /// Simple function to check for input validity
    func isValid() -> Bool {
        !name.isEmpty && bandId != 0
    }
    
    // MARK: - Public methods
    
    func createOrEditSongBook() {
        if !isValid() {
            return
        }
        
        state = .submitting
        Task {
            await createOrEditSongBook()
        }
    }
    
    func createOrEditSongBook() async {
        let dto = SongBookEditDTO(name: name, bandId: bandId)
        let result: Result<SongBookDTO, HttpStatusError>
        if let editSongBook = editSongBook {
            result = await songBookService.edit(id: editSongBook.id, songBook: dto)
        }
        else {
            result = await songBookService.create(songBook: dto)
        }
        await createOrEdit(editSongBook: editSongBook, result: result)
    }
    
    // MARK: - Private methods
        
    @MainActor
    private func createOrEdit(editSongBook: SongBook?, result: Result<SongBookDTO, HttpStatusError>) async {
        switch result {
        case .success(let songBook):
            // Find existing SongBook and replace it
            if let editSongBook = editSongBook {
                guard let index = songBookListViewModel.songBooks.firstIndex(where: {
                    $0.id == editSongBook.id
                }) else {
                    state = .success
                    return
                }
                songBookListViewModel.songBooks[index] = songBook.domain
                // Update Mac index
                if editSongBook.id == appState.songBook?.id {
                    appState.songBook = songBook.domain
                }
            }
            // Create new SongBook
            else {
                songBookListViewModel.songBooks.append(songBook.domain)
            }
            state = .success
        case .failure(let error):
            print(error)
            state = .failure(error.errorDescription)
        }
    }
}
