//
//  SongEditView.swift
//  View
//
//  Created by Ondřej Wrzecionko on 14.03.2022.
//

import SwiftUI

struct SongEditView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var appState: AppState
    @ObservedObject private var songBookListViewModel: SongBookListViewModel
    @StateObject private var songEditViewModel: SongEditViewModel
    @State private var isEditSongDone: Bool = true
    
    // MARK: - Init
    init(
        editSong: EditModel<Song>,
        songBookListViewModel: SongBookListViewModel
    ) {
        let song: Song?
        if case .edit(let _song) = editSong { song = _song }
        else { song = nil }
        
        _songBookListViewModel = ObservedObject(
            wrappedValue: songBookListViewModel
        )
        _songEditViewModel = StateObject(
            wrappedValue: SongEditViewModel(
                context: context,
                songBookListViewModel: songBookListViewModel,
                song: song
            )
        )
    }
    
    // MARK: - View
    
    var body: some View {
        SheetView(large: true) {
            VStack {
                switch songEditViewModel.state {
                case .idle:
                    switch songBookListViewModel.state {
                    case .loading:
                        ProgressView()
                    case .failure(let error):
                        ErrorView(
                            error: error,
                            action: songBookListViewModel.loadSongBooks,
                            dismiss: { appState.editSong = nil },
                            offline: nil
                        )
                    case .success:
                        if songBookListViewModel.songBooks.isEmpty {
                            ErrorView(
                                error: NSLocalizedString("cannot_create_song", comment: ""),
                                action: nil,
                                dismiss: { appState.editSong = nil },
                                offline: nil
                            )
                        }
                        else {
                            SongFormView(
                                songEditViewModel: songEditViewModel,
                                songBookListViewModel: songBookListViewModel,
                                songBooks: $songBookListViewModel.songBooks
                            )
                        }

                    }
                case .submitting:
                    ProgressView()
                case .failure(let error):
                    ErrorView(
                        error: error,
                        action: songEditViewModel.createOrEditSong,
                        dismiss: { appState.editSong = nil },
                        offline: songEditViewModel.saveOffline
                    )
                case .success:
                    ProgressView()
                        .alert(
                            songEditViewModel.editing ? "song_edit_success"
                                : "song_create_success",
                            isPresented: $isEditSongDone
                        ) {
                            Button("button_ok") {
                                isEditSongDone = false
                                appState.editSong = nil
                            }
                        }
                }
            }
            .navigationTitle(songEditViewModel.editing ? "song_edit" : "song_create")
        }
    }
}
