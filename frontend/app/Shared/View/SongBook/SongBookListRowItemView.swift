//
//  SongBookListRowItemView.swift
//  View
//
//  Created by Ondřej Wrzecionko on 12.03.2022.
//

import SwiftUI

struct SongBookListRowItemView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var appState: AppState
    
    let song: Song
    @Binding var songBook: SongBook
    let songBookDetail: Bool
    
    // MARK: - View
    
    var body: some View {
        HStack {
            Text(song.displayName)
                .font(.system(size: appState.defaultFontSize))
                .padding([.leading], 4)
                .foregroundColor(_lightColor)
            Spacer()
            
            if appState.editMode {
                if songBookDetail {
                    if songBook.canEdit(user: appState.user) {
                        // Edit song
                        Button(action: { appState.editSong = .edit(song) }) {
                            Image(systemName: "pencil.circle.fill")
                                .resize(appState: appState)
                        }
                        .buttonStyle(_buttonStyle)
                    
                        // Delete song
                        Button(action: { appState.deleteSong = song }) {
                            Image(systemName: "xmark.circle.fill")
                                .resize(appState: appState)
                        }
                        .buttonStyle(.borderless)
                    }
                }
                else {
                    // Remove from playlist
                    if let playlistOrder = appState.playlist.songs.firstIndex(of: song) {
                        Button(action: {
                            withAnimation {
                                appState.playlist.songs.remove(atOffsets: IndexSet(integer: playlistOrder))
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .resize(appState: appState)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                    // Add to playlist
                    else if !appState.playlist.songs.contains(where: { $0.songId == song.songId }) {
                        Button(action: {
                            withAnimation {
                                appState.playlist.songs.append(song.addToPlaylist())
                            }
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .resize(appState: appState)
                        }
                        .buttonStyle(_buttonStyle)
                    }
                }
            }
        }
        .padding(4)
    }
}
