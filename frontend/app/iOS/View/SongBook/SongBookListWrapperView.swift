//
//  SongBookListWrapperView.swift
//  View (iOS)
//
//  Created by Ondřej Wrzecionko on 12.03.2022.
//

import SwiftUI

struct SongBookListWrapperView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var appState: AppState
    @ObservedObject var songBookListViewModel: SongBookListViewModel
    
    // MARK: - View
    
    var body: some View {
        ScrollViewReader { reader in
            List {
                ForEach([$appState.playlist.songBook] + $songBookListViewModel.songBooks.filter {
                    !appState.songBookFilter.contains($0.id)
                }.sorted {
                    $0.wrappedValue.name.localizedCompare($1.wrappedValue.name) == .orderedAscending
                }) { songBook in
                    SongBookListRowView(
                        songBookListViewModel: songBookListViewModel,
                        selectedSongId: $songBookListViewModel.selectedSongId,
                        songBook: songBook,
                        scrollToTop: { reader.scrollTo(Playlist.id) }
                    )
                }
            }
            .searchable(text: $appState.songBookSearch, placement: .navigationBarDrawer(displayMode: .always))
            .disableAutocorrection(true)
        }
    }
}
