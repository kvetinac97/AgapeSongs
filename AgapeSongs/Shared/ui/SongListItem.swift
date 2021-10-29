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
            if song.listId == 0 {
                Button("Remove from playlist") {
                    playlistHolder.lists[0].songs.remove(at: song.songId)
                    recalcIndexesAndSave()
                }
                if song.songId != 0 {
                    Button("Move up") {
                        swapAndSave(first: song.songId, second: song.songId - 1)
                    }
                }
                if song.songId != playlistHolder.lists[0].songs.endIndex - 1 {
                    Button("Move down") {
                        swapAndSave(first: song.songId, second: song.songId + 1)
                    }
                }
            }
            else {
                Button("Add to playlist") {
                    let cpSong = Song(id: "P: " + song.id, lines: song.lines, realId: song.realId, realListId: song.realListId, listId: 0, songId: 0)
                    playlistHolder.lists[0].songs.append(cpSong)
                    recalcIndexesAndSave()
                }
            }
        }))
    }
    
    // Swap two items and save playlist changes
    private func swapAndSave (first: Int, second: Int) {
        playlistHolder.lists[0].songs.swapAt(first, second)
        playlistHolder.lists[0].songs[first].songId = first
        playlistHolder.lists[0].songs[second].songId = second
        playlistHolder.savePlaylist()
    }
    
    // Recalculate indexes
    private func recalcIndexesAndSave () {
        if playlistHolder.lists[0].songs.count > 0 {
            for i in 0...playlistHolder.lists[0].songs.count - 1 {
                playlistHolder.lists[0].songs[i].songId = i
            }
        }
        playlistHolder.savePlaylist()
    }
    
}
