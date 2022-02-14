//
//  SongListItem.swift
//  AgapeSongs
//
//  Created by Ondřej Wrzecionko on 17.06.2021.
//

import SwiftUI

/*
 * One menu song list item
 */
struct SongListItem: View {
    
    // All playlists holder
    @EnvironmentObject var playlistHolder: PlaylistHolder
    
    // Selected song, actual song
    @Binding var selection: Song?
    @Binding var editMode: Bool
    
    // Current song being displayed
    let song: Song
    
    var body : some View {
        ZStack {
            if selection?.id == song.id {
                Color.blue
            }
            else {
                Color.black
            }

            HStack {
                #if os(macOS)
                let size = 16
                #else
                let size = UIDevice.current.userInterfaceIdiom == .pad ? 32 : 16
                #endif
                
                Text(song.id)
                    .font(.system(size: CGFloat(size)))
                    .padding([.leading], 4)
                    .foregroundColor(.white)
                
                Spacer()
            }
            .padding(4)
        }
        .onTapGesture {
            if !editMode {
                selection = song
            }
        }
        .contextMenu(ContextMenu(menuItems: {
            if song.listId != 0 && !playlistHolder.lists[0].songs.contains(where: { $0.realId == song.realId }) {
                Button("Add to playlist") {
                    let cpSong = Song(id: "P: " + song.id, lines: song.lines, realId: song.realId, realListId: song.realListId, listId: 0)
                    playlistHolder.lists[0].songs.append(cpSong)
                }
            }
        }))
    }
    
    // Swap two items and save playlist changes
    private func swapAndSave (first: Int, second: Int) {
        withAnimation(.default) {
            playlistHolder.lists[0].songs.swapAt(first, second)
        }
        playlistHolder.savePlaylist()
    }
    
}
