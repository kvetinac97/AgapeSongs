//
//  SongBookView.swift
//  View (iOS)
//
//  Created by Ondřej Wrzecionko on 14.03.2022.
//

import SwiftUI

struct SongBookView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var appState: AppState
    @StateObject var songBookViewModel: SongBookViewModel
    @Binding var songBook: SongBook
    
    @State private var isCreateSongDisplayed: Bool = false
    @State private var isDeleteSongDisplayed: Bool = false
    @State private var editSong: Song? = nil
    @State private var deleteSong: Song? = nil
        
    // MARK: - View
    
    var body: some View {
        EditModeStackView {
            let songs = songBook.songs.filter { $0.matches(appState.songBookSearch) != .nomatch }.sorted {
                $0.compare(songBookSearch: appState.songBookSearch, to: $1, playlist: appState.playlist)
            }
            
            if !songs.isEmpty {
                List {
                    Section("songbook_songs") {
                        ForEach(songs) { song in
                            let songListView = SongBookListRowItemView(
                                song: song,
                                songBook: $songBook,
                                songBookDetail: true
                            )
                            
                            if !appState.editMode {
                                // SwiftUI bad context menu updating workaround
                                let containsSong = appState.playlist.songs.contains(where: { $0.songId == song.songId })
                                let link = NavigationLink(
                                    destination: SongView(songBook: $songBook),
                                    tag: song.idString,
                                    selection: $songBookViewModel.selectedSongId
                                ) { songListView }
                                
                                if containsSong {
                                    link.createContextMenu(appState: appState, song: song, scrollToTop: {})
                                }
                                else {
                                    link.createContextMenu(appState: appState, song: song, scrollToTop: {})
                                }
                            }
                            else {
                                songListView
                            }
                        }
                    }
                }
                .searchable(text: $appState.songBookSearch, placement: .sidebar)
            }
            else {
                Text("songbook_empty")
            }
        }
        .navigationTitle(songBook.name)
        .applySongBookModifiers(appState: appState, songBook: songBook)
        .onAppear { appState.songBook = songBook }
    }
}
