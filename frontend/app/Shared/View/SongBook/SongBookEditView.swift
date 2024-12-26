//
//  SongBookEditView.swift
//  View
//
//  Created by Ondřej Wrzecionko on 14.03.2022.
//

import SwiftUI

struct SongBookEditView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var appState: AppState
    @StateObject private var bandListViewModel: BandListViewModel
    @StateObject private var songBookEditViewModel: SongBookEditViewModel
    @State private var isEditSongBookDone: Bool = true
    
    // MARK: - Init
    init(
        editSongBook: EditModel<SongBook>,
        songBookListViewModel: SongBookListViewModel
    ) {
        let songBook: SongBook?
        if case .edit(let songbook) = editSongBook { songBook = songbook }
        else { songBook = nil }
        
        _bandListViewModel = StateObject(wrappedValue: BandListViewModel(context: context))
        _songBookEditViewModel = StateObject(
            wrappedValue: SongBookEditViewModel(
                context: context,
                songBookListViewModel: songBookListViewModel,
                songBook: songBook
            )
        )
    }
    
    // MARK: - View
    
    var body: some View {
        SheetView {
            VStack {
                switch songBookEditViewModel.state {
                case .idle:
                    switch bandListViewModel.state {
                    case .loading:
                        ProgressView()
                    case .failure(let error):
                        ErrorView(
                            error: error,
                            action: bandListViewModel.loadBands,
                            dismiss: { appState.editSongBook = nil },
                            offline: nil
                        )
                    case .success:
                        SongBookFormView(
                            songBookEditViewModel: songBookEditViewModel,
                            bandListViewModel: bandListViewModel,
                            bands: $bandListViewModel.bands
                        )
                    case .empty:
                        ErrorView(
                            error: NSLocalizedString("cannot_create_songbook", comment: ""),
                            action: nil,
                            dismiss: { appState.editSongBook = nil },
                            offline: nil
                        )
                    }
                case .submitting:
                    ProgressView()
                case .failure(let error):
                    ErrorView(
                        error: error,
                        action: songBookEditViewModel.createOrEditSongBook,
                        dismiss: { appState.editSongBook = nil },
                        offline: nil
                    )
                case .success:
                    ProgressView()
                        .alert(
                            songBookEditViewModel.editing ? "songbook_edit_success"
                                : "songbook_create_success",
                            isPresented: $isEditSongBookDone
                        ) {
                            Button("button_ok") {
                                isEditSongBookDone = false
                                appState.editSongBook = nil
                            }
                        }
                }
            }
            .navigationTitle(songBookEditViewModel.editing ? "songbook_edit"
                                : "songbook_create")
        }
    }
}
