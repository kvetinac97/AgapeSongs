//
//  PlaylistDropDelegate.swift
//  AgapeSongs
//
//  Created by Ondřej Wrzecionko on 14.02.2022.
//

import SwiftUI

struct PlaylistDropDelegate : DropDelegate {
    
    // Playlist
    @Binding var playlist: Playlist
    
    // Current song and dragged song
    let song: Song?
    @Binding var draggedSong: Song?
    
    let savePlaylist: () -> Void
    
    func performDrop(info: DropInfo) -> Bool {
        return true
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        guard let draggedSong = draggedSong else { return DropProposal(operation: .forbidden) }
        
        // Add to end of playlist
        if song == nil && !playlist.songs.contains(draggedSong) {
            return DropProposal(operation: .copy)
        }
        
        guard let song = song else { return DropProposal(operation: .forbidden) }
        
        // Cannot reorder in list
        if !playlist.songs.contains(draggedSong) && !playlist.songs.contains(song) {
            return DropProposal(operation: .forbidden)
        }
        
        // Moving inside of playlist or removing from playlist
        if playlist.songs.contains(draggedSong) {
            return DropProposal(operation: .move)
        }

        // Add song to playlist
        return DropProposal(operation: .copy)
    }
    
    func dropEntered(info: DropInfo) {
        guard let draggedSong = draggedSong else { return }

        withAnimation(.default) {
            // Add new song to playlist
            if song == nil {
                let cpSong = Song(id: "P: " + draggedSong.id, lines: draggedSong.lines, realId: draggedSong.realId, realListId: draggedSong.realListId, listId: 0)
                
                playlist.songs.append(cpSong)
                self.draggedSong = cpSong
                savePlaylist()
                return
            }
            
            guard let song = song else { return }
            
            // Add song to playlist
            let index = playlist.songs.firstIndex(of: song)
            let draggedIndex = playlist.songs.firstIndex(of: draggedSong)
            
            // Adding new songs
            if draggedIndex == nil {
                guard let songIndex = index else { return }
                let cpSong = Song(id: "P: " + draggedSong.id, lines: draggedSong.lines, realId: draggedSong.realId, realListId: draggedSong.realListId, listId: 0)
                
                playlist.songs.insert(cpSong, at: songIndex)
                self.draggedSong = cpSong
                savePlaylist()
                return
            }
            
            // Removing playlist songs
            if index == nil {
                guard let draggedSongIndex = draggedIndex else { return }
                playlist.songs.remove(at: draggedSongIndex)
                self.draggedSong = Song(id: draggedSong.realId, lines: draggedSong.lines, realId: draggedSong.realId, realListId: draggedSong.realListId, listId: draggedSong.realListId)
                savePlaylist()
                return
            }
            
            // Moving current songs
            guard var songIndex = index, var draggedSongIndex = draggedIndex else { return }

            if draggedSongIndex < songIndex {
                let tmpSongIndex = songIndex
                songIndex = draggedSongIndex
                draggedSongIndex = tmpSongIndex
            }
            
            playlist.songs.move(fromOffsets: IndexSet(integer: draggedSongIndex), toOffset: songIndex)
            savePlaylist()
        }
    }
    
    func validateDrop(info: DropInfo) -> Bool {
        guard let draggedSong = draggedSong else { return false }
        if song == nil && !playlist.songs.contains(draggedSong) { return true }
        
        guard let song = song else { return false }
        if playlist.songs.contains(where: { $0.realId == draggedSong.realId }) && !playlist.songs.contains(draggedSong) { return false }
        return draggedSong != song && (playlist.songs.contains(song) || playlist.songs.contains(draggedSong))
    }
    
}
