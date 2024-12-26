//
//  SongBookListView.swift
//  View
//
//  Created by Ondřej Wrzecionko on 10.03.2022.
//

import SwiftUI

struct SongBookListView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var appState: AppState
    @ObservedObject var songBookListViewModel: SongBookListViewModel
    @State private var isSongBookFilterDisplayed: Bool = false
    
    // MARK: - View
    
    var body: some View {
        VStack {
            switch songBookListViewModel.state {
            case .loading:
                ProgressView()
            case .failure(let error):
                ErrorView(error: error, action: songBookListViewModel.loadSongBooks, dismiss: nil, offline: nil)
            case .success:
                ZStack {
                    EditModeStackView {
                        SongBookListWrapperView(songBookListViewModel: songBookListViewModel)
                            .applyModifiers(
                                appState: _appState,
                                songBookListViewModel: _songBookListViewModel,
                                isSongBookFilterDisplayed: $isSongBookFilterDisplayed
                            )
                    }
                    
                    if songBookListViewModel.songBooks.filter({ $0.id != Playlist.id }).isEmpty {
                        VStack {
                            Text("songbook_list_empty")
                                .font(.system(size: appState.defaultFontSize))
                                .padding()
                        }
                    }
                }
                .onOpenURL(perform: songBookListViewModel.openURL)
            }
        }
        .navigationTitle("songbook_list")
    }
}
