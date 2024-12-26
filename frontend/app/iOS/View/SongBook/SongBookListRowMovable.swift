//
//  SongBookListRowMovable.swift
//  View (iOS)
//
//  Created by Ondřej Wrzecionko on 20.03.2022.
//

import SwiftUI

extension ForEach where Data.Element == Song, ID == [Int], Content: View {
    /// Enables drag & drop in given list
    @ViewBuilder func makeMovable(appState: AppState, songBook: SongBook) -> some View {
        if songBook.id != Playlist.id {
            self
        }
        else {
            self.onMove { (from, to) in
                withAnimation {
                    appState.playlist.songs.move(
                        fromOffsets: from,
                        toOffset: to
                    )
                }
            }.onDelete { indexes in
                appState.playlist.songs.remove(atOffsets: indexes)
            }
        }
    }
}
