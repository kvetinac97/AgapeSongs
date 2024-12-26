//
//  SongBookListFilterView.swift
//  View
//
//  Created by Ondřej Wrzecionko on 14.03.2022.
//

import SwiftUI

struct SongBookListFilterView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var appState: AppState
    @ObservedObject var songBookListViewModel: SongBookListViewModel
    @Binding var isSongBookFilterDisplayed: Bool
    
    // MARK: - View
    
    var body: some View {
        VStack {
            List {
                Section("songbook_filter_songbooks") {
                    ForEach(songBookListViewModel.songBooks) { songBook in
                        Button(action: {
                            if let index = appState.songBookFilter.firstIndex(of: songBook.id) {
                                appState.songBookFilter.remove(at: index)
                            }
                            else {
                                appState.songBookFilter.append(songBook.id)
                            }
                        }) {
                            HStack {
                                Text(songBook.name)
                                Spacer()
                                if !appState.songBookFilter.contains(songBook.id) {
                                    Image(systemName: "checkmark")
                                }
                            }
                            .foregroundColor(Color("Light"))
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
                
                Section("songbook_filter_actions") {
                    HStack {
                        Button("songbook_filter_hide_all") {
                            appState.songBookFilter = songBookListViewModel.songBooks.map { $0.id }
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        Spacer()
                        Button("songbook_filter_show_all") {
                            appState.songBookFilter = []
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                    HStack {
                        Spacer()
                        Button("songbook_filter_reload") {
                            songBookListViewModel.loadSongBooks()
                        }
                        .buttonStyle(_buttonStyle)
                        Spacer()
                    }
                }
            }
        }
    }
}
