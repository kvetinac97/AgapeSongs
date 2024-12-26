//
//  SongBookListWrapperView.swift
//  View (macOS)
//
//  Created by Ondřej Wrzecionko on 12.03.2022.
//

import SwiftUI

/// SongBook view wrapper on macOS
/// Uses split view, custom Navigation solution due to SwiftUI buggy behaviour
struct SongBookListWrapperView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var appState: AppState
    @ObservedObject var songBookListViewModel: SongBookListViewModel
    
    // MARK: - View
    
    var body: some View {
        VStack {
            let songBooks = $songBookListViewModel.songBooks.filter { !appState.songBookFilter.contains($0.id)
            }.sorted {
                $0.wrappedValue.name.localizedCompare($1.wrappedValue.name) == .orderedAscending
            }
            ScrollView {
                ScrollViewReader { reader in
                    LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
                        ForEach([$appState.playlist.songBook] + songBooks) { songBook in
                            SongBookListRowView(
                                selectedSongId: $songBookListViewModel.selectedSongId,
                                songBookListViewModel: _songBookListViewModel,
                                songBook: songBook,
                                scrollToTop: { reader.scrollTo(Playlist.id) }
                            ) { song in
                                SongBookListRowItemView(
                                    song: song.wrappedValue,
                                    songBook: songBook,
                                    songBookDetail: false
                                )
                            }
                        }
                    }
                }
            }
            
            TextField("songbook_search", text: $appState.songBookSearch)
                .padding()
        }
        .background(KeyEventHandling(
            songBookSearch: $appState.songBookSearch,
            selectedSongId: $songBookListViewModel.selectedSongId,
            songsById: $songBookListViewModel.songsById,
            filteredSongBookIds: $appState.songBookFilter,
            playlist: $appState.playlist,
            selectedSongBook: $appState.songBook,
            isWindowFloating: $appState.isWindowFloating
        ))
        .onAppear {
            songBookListViewModel.selectedSongId = appState.song?.idString
        }
    }
}
