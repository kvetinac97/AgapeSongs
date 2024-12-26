//
//  SongBookView.swift
//  View (macOS)
//
//  Created by Ondřej Wrzecionko on 14.03.2022.
//

import SwiftUI

struct SongBookView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var appState: AppState
    @StateObject var songBookViewModel: SongBookViewModel
    
    @ObservedObject var songBookListViewModel: SongBookListViewModel
    @Binding var songBook: SongBook
    
    // MARK: - Init
    
    init(songBookListViewModel: SongBookListViewModel, songBook: Binding<SongBook>) {
        _songBookListViewModel = ObservedObject(wrappedValue: songBookListViewModel)
        _songBookViewModel = StateObject(
            wrappedValue: SongBookViewModel(context: context, _songBook: songBook)
        )
        _songBook = songBook
    }
    
    // MARK: - View
    
    var body: some View {
        EditModeStackView {
            VStack {
                ScrollView {
                    ScrollViewReader { reader in
                        LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
                            SongBookListRowView(
                                selectedSongId: $songBookViewModel.selectedSongId,
                                songBookListViewModel: _songBookListViewModel,
                                songBook: $songBook,
                                scrollToTop: {}
                            ) { song in
                                SongBookListRowItemView(
                                    song: song.wrappedValue,
                                    songBook: $songBook,
                                    songBookDetail: true
                                )
                            }
                        }
                    }
                }
                TextField("songbook_search", text: $appState.songBookSearch)
                    .padding()
            }
        }
        .navigationTitle(songBook.name)
        .applySongBookModifiers(
            appState: appState,
            songBook: songBook,
            backButton: true
        )
    }
}
