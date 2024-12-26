//
//  SongPlaylistNavigationView.swift
//  View (iOS)
//
//  Created by Ondřej Wrzecionko on 23.03.2022.
//

import SwiftUI

struct SongPlaylistNavigationView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var appState: AppState
    let song: Song
    
    // MARK: - View
    
    var body: some View {
        if let playlistPosition = appState.playlist.songs.firstIndex(of: song) {
            HStack {
                if appState.playlist.songs.first != song {
                    createArrow(previous: true, index: playlistPosition)
                }
                Spacer()
                if appState.playlist.songs.last != song {
                    createArrow(previous: false, index: playlistPosition)
                }
            }
            .padding([.bottom], 50)
            .padding([.leading, .trailing], 30)
        }
    }
    
    // MARK: - Private helpers
    
    private func createArrow(previous: Bool, index: Int) -> some View {
        Image(systemName: previous ? "arrow.left.circle.fill" : "arrow.right.circle.fill")
            .resizable()
            .frame(width: 50, height: 50)
            .foregroundColor(.blue.opacity(0.5))
            .padding(previous ? [.leading] : [.trailing])
            .onTapGesture {
                appState.song = appState.playlist.songs[index + (previous ? -1 : 1)]
            }
    }
}
