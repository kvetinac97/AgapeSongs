//
//  SongBookListRowView.swift
//  View (macOS)
//
//  Created by Ondřej Wrzecionko on 12.03.2022.
//

import SwiftUI
import UniformTypeIdentifiers

struct SongBookListRowView<Content>: View where Content: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var appState: AppState
    @ObservedObject var songBookListViewModel: SongBookListViewModel
    
    @Binding var selectedSongId: String?
    @State var draggedSong: Song?
    
    @Binding var songBook: SongBook
    private let scrollToTop: () -> ()
    private let content: (Binding<Song>) -> Content
    
    // MARK: - Init
    
    init(
        selectedSongId: Binding<String?>,
        songBookListViewModel: ObservedObject<SongBookListViewModel>,
        songBook: Binding<SongBook>,
        scrollToTop: @escaping () -> (),
        @ViewBuilder content: @escaping (Binding<Song>) -> Content
    ) {
        _selectedSongId = selectedSongId
        _songBookListViewModel = songBookListViewModel
        _songBook = songBook
        self.scrollToTop = scrollToTop
        self.content = content
    }
    
    // MARK: - View
    
    var body: some View {
        Section(content: { list }, header: { header })
    }
    
    var header: some View {
        SongBookListRowHeaderView(
            songBookListViewModel: songBookListViewModel,
            songBook: $songBook,
            showImage: false
        ).onTapGesture {
            if songBook.id != Playlist.id {
                appState.songBook = songBook
            }
        }
        .background(.background)
    }
    
    var list: some View {
        VStack(spacing: 0) {
            let songs = $songBook.songs.filter {
                $0.wrappedValue.matches(appState.songBookSearch) != .nomatch
            }.sorted {
                $0.wrappedValue.compare(songBookSearch: appState.songBookSearch,
                                        to: $1.wrappedValue, playlist: appState.playlist)
            }
            ForEach(songs) { song in
                ZStack {
                    Rectangle()
                        .foregroundColor(appState.selectedSongId == song.wrappedValue.idString ? .blue : .black)
                    content(song)
                }
                .onTapGesture {
                    selectedSongId = song.wrappedValue.idString
                }
                .createContextMenu(appState: appState, song: song.wrappedValue, scrollToTop: scrollToTop)
                .makeDraggable(draggedSong: $draggedSong, song: song.wrappedValue)
                .onDrop(
                    of: [UTType.text],
                    delegate: PlaylistDropDelegate(
                        appState: appState,
                        draggedSong: $draggedSong,
                        song: song
                    )
                )
            }
            
            if songs.isEmpty {
                SongBookListEmptyView()
            }
        }
    }
}
