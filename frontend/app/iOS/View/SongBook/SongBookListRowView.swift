//
//  SongBookListRowView.swift
//  View (iOS)
//
//  Created by Ondřej Wrzecionko on 10.03.2022.
//

import SwiftUI
import UniformTypeIdentifiers

struct SongBookListRowView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var appState: AppState
    @ObservedObject var songBookListViewModel: SongBookListViewModel
    
    @Binding var selectedSongId: String?
    @State var draggedSong: Song? = nil
    
    @Binding var songBook: SongBook
    let scrollToTop: () -> ()
    
    // MARK: - View
    
    var body: some View {
        Section(content: {
            let songs: [Song] = songBook.songs.filter {
                $0.matches(appState.songBookSearch) != .nomatch
            }.sorted {
                $0.compare(songBookSearch: appState.songBookSearch, to: $1, playlist: appState.playlist)
            }
            
            ForEach(songs) { song in
                let songListView = SongBookListRowItemView(
                    song: song,
                    songBook: $songBook,
                    songBookDetail: false
                )
                
                VStack {
                    if !appState.editMode {
                        // SwiftUI bad context menu updating workaround
                        let containsSong = appState.playlist.songs.contains(where: { $0.songId == song.songId })
                        let link = NavigationLink(
                            destination: SongView(songBook: $songBook),
                            tag: song.idString,
                            selection: $selectedSongId
                        ) { songListView }
                        
                        if containsSong {
                            link.createContextMenu(appState: appState, song: song, scrollToTop: scrollToTop)
                        }
                        else {
                            link.createContextMenu(appState: appState, song: song, scrollToTop: scrollToTop)
                        }
                    }
                    else {
                        songListView
                    }
                }
                .makeDraggable(draggedSong: $draggedSong, song: song)
            }
            .makeMovable(appState: appState, songBook: songBook)
        }, header: {
            let headerView = SongBookListRowHeaderView(
                songBookListViewModel: songBookListViewModel,
                songBook: $songBook,
                showImage: true
            )
            if songBook.id != Playlist.id {
                NavigationLink(destination: SongBookView(songBookViewModel: SongBookViewModel(context: context, _songBook: $songBook), songBook: $songBook)) {
                    headerView
                }
            }
            else { headerView }
        })
    }
}
