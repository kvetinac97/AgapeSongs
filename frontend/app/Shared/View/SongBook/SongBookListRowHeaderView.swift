//
//  SongBookListRowHeaderView.swift
//  View
//
//  Created by Ondřej Wrzecionko on 12.03.2022.
//

import SwiftUI

struct SongBookListRowHeaderView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var appState: AppState
    @ObservedObject var songBookListViewModel: SongBookListViewModel
    
    @Binding var songBook: SongBook
    let showImage: Bool
    
    // MARK: - View
    
    var body: some View {
        HStack {
            #if os(macOS)
            let canShow = songBook.id != appState.songBook?.id
            #else
            let canShow = true
            #endif
            
            Text(songBook.name)
                .font(.system(size: appState.defaultFontSize * 0.7, weight: .bold))
            if songBook.id != Playlist.id {
                #if os(macOS)
                // Display step-in arrow
                if appState.songBook?.id != songBook.id {
                    Button(action: { appState.songBook = songBook }) {
                        Image(systemName: "arrow.right.circle.fill")
                            .resize(appState: appState)
                    }
                    .buttonStyle(_buttonStyle)
                }
                #else
                if showImage {
                    Image(systemName: "arrow.right.circle.fill")
                        .resize(appState: appState)
                }
                #endif
                if appState.editMode && canShow && songBook.band.canEdit(user: appState.user) {
                    Button(action: { appState.editSongBook = .edit(songBook) }) {
                        Image(systemName: "pencil.circle.fill")
                            .resize(appState: appState)
                    }
                    .buttonStyle(_buttonStyle)
                    Button(action: { appState.deleteSongBook = songBook }) {
                        Image(systemName: "xmark.circle.fill")
                            .resize(appState: appState)
                    }
                    .buttonStyle(_buttonStyle)
                }
            }
            else {
                // Display ProgressView | upload / download playlist button
                if songBookListViewModel.isPlaylistEditLoading {
                    ProgressView()
                        .controlSize(.small)
                        .padding([.leading, .trailing], 1)
                }
                else {
                    Button(action: { songBookListViewModel.savePlaylist() }) {
                        Image(systemName: "square.and.arrow.up.fill")
                            .resize(appState: appState)
                    }
                    .buttonStyle(_buttonStyle)
                    .confirmationDialog(
                        "playlist_upload_choose_band",
                        isPresented: $songBookListViewModel.isSelectPlaylistEditDisplayed
                    ) {
                        ForEach(songBookListViewModel.playlistBands.filter {
                            $0.canEdit(user: appState.user)
                        }) { band in
                            Button(band.name) {
                                songBookListViewModel.savePlaylist(bandId: band.id)
                            }
                            .textCase(nil)
                        }
                    }
                }
                if songBookListViewModel.isPlaylistViewLoading {
                    ProgressView()
                        .controlSize(.small)
                        .padding([.leading, .trailing], 1)
                }
                else {
                    Button(action: { songBookListViewModel.loadPlaylist() }) {
                        Image(systemName: "square.and.arrow.down.fill")
                            .resize(appState: appState)
                    }
                    .buttonStyle(_buttonStyle)
                    .confirmationDialog(
                        "playlist_download_choose_band",
                        isPresented: $songBookListViewModel.isSelectPlaylistViewDisplayed
                    ) {
                        ForEach(songBookListViewModel.playlistBands) { band in
                            Button(band.name) {
                                songBookListViewModel.loadPlaylist(bandId: band.id)
                            }
                            .textCase(nil)
                        }
                    }
                }
                Button(action: { songBookListViewModel.isDeletePlaylistViewDisplayed = true }) {
                    Image(systemName: "trash.fill")
                        .resize(appState: appState)
                }
                .buttonStyle(_buttonStyle)
                .confirmationDialog(
                    "playlist_delete_confirm",
                    isPresented: $songBookListViewModel.isDeletePlaylistViewDisplayed
                ) {
                    Button("button_delete", role: .destructive) {
                        appState.playlist.songs = []
                    }
                    .textCase(nil)
                }
            }
            Spacer()
        }
        .padding(showImage ? 0 : 5)
    }
}
