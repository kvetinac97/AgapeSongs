//
//  SongBookListRowContextMenu.swift
//  View
//
//  Created by Ondřej Wrzecionko on 14.03.2022.
//

import SwiftUI

extension View {
    /// Activates context menu on given item
    func createContextMenu(appState: AppState, song: Song, scrollToTop: @escaping () -> ()) -> some View {
        self.contextMenu {
            if !song.inPlaylist {
                if !appState.playlist.songs.contains(where: { $0.songId == song.songId }) {
                    Button("song_add_to_playlist") {
                        appState.playlist.songs.append(song.addToPlaylist())
                    }
                    let path = NetworkService.Constants.apiLocation + "/song/" + String(song.songId)
                    if let url = URL(string: path + "/opensong") {
                        Link("song_export_opensong", destination: url)
                    }
                    if let url = URL(string: path + "/text") {
                        Link("song_export_pdf", destination: url)
                    }
                }
            }
        }
    }
}
