//
//  PlaylistDropDelegate.swift
//  ViewModel (macOS)
//
//  Created by Ondřej Wrzecionko on 20.03.2022.
//

import SwiftUI

struct PlaylistDropDelegate: DropDelegate {
    
    // MARK: - Properties
    
    let appState: AppState
    @Binding var draggedSong: Song?    
    @Binding var song: Song
    
    // MARK: - Protocol methods
    
    func performDrop(info: DropInfo) -> Bool {
        // Must have something to move, cannot move itself
        guard let draggedSong = draggedSong, draggedSong.id != song.id else {
            return false
        }
        
        // Reorder inside of playlist
        return true
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        // Must have something to move, cannot move itself
        guard let draggedSong = draggedSong, draggedSong.id != song.id else {
            return DropProposal(operation: .forbidden)
        }
        
        // Reorder inside of playlist
        return DropProposal(operation: .move)
    }
    
    func dropEntered(info: DropInfo) {
        // Must have something to move, cannot move itself
        guard let draggedSong = draggedSong,
              draggedSong.id != song.id,
              let draggedIndex = appState.playlist.songs.firstIndex(of: draggedSong),
              let songIndex = appState.playlist.songs.firstIndex(of: song) else {
            return
        }
        
        // Arrange indexes properly
        let minIndex = draggedIndex < songIndex ? draggedIndex : songIndex
        let maxIndex = draggedIndex < songIndex ? songIndex : draggedIndex
        
        // Reorder inside of playlist
        withAnimation(.default) {         
            appState.playlist.songs.move(
                fromOffsets: IndexSet(integer: maxIndex),
                toOffset: minIndex
            )
        }
    }
    
    func validateDrop(info: DropInfo) -> Bool {
        // Must have something to move
        guard let draggedSong = draggedSong, draggedSong.id != song.id else {
            return false
        }
        
        // Reorder inside of playlist
        return true
    }
}
