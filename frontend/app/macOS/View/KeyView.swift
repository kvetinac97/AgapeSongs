//
//  KeyView.swift
//  View (macOS)
//
//  Created by Ondřej Wrzecionko on 12.03.2022.
//

import Cocoa
import SwiftUI

class KeyView: NSView {
    
    // MARK: - Properties
    
    var songBookSearch: Binding<String> = .constant("")
    var selectedSongId: Binding<String?> = .constant(nil)
    var songsById: Binding<[String: Song]> = .constant([String: Song]())
    var filteredSongBookIds: Binding<[Int]> = .constant([Int]())
    var playlist: Binding<Playlist> = .constant(Playlist(songs: []))
    var selectedSongBook: Binding<SongBook?> = .constant(nil)

    override var acceptsFirstResponder: Bool { true }

    override func keyDown (with event: NSEvent) {
        switch event.keyCode {
        // Move selected song
        case Key.arrowup, Key.arrowdown, Key.arrowleft, Key.arrowright:
            moveSelection(event.keyCode == Key.arrowdown || event.keyCode == Key.arrowright ? 1 : -1)
        case Key.backspace:
            if !songBookSearch.wrappedValue.isEmpty {
                // Remove whole text
                if event.modifierFlags.contains(.command) {
                    songBookSearch.wrappedValue = ""
                }
                // Remove last word
                else if event.modifierFlags.contains(.option) {
                    songBookSearch.wrappedValue = songBookSearch.wrappedValue.components(separatedBy: " ").dropLast().joined(separator: " ")
                }
                // Remove last character
                else {
                    songBookSearch.wrappedValue.removeLast()
                }
            }
        // Add written text
        default:
            if let text = event.characters?.filter({ $0.isLetter || $0.isNumber || $0.isPunctuation || $0 == " " }), !text.isEmpty {
                songBookSearch.wrappedValue += text
            }
            break
        }
    }
    
    // MARK: - Helpers
    
    private func moveSelection(_ change: Int) {
        // Playlist songs by id
        let playlistSongsById = playlist.songs.wrappedValue.reduce(into: [String: Song]()) {
            $0[$1.idString] = $1
        }
        
        // Prepare songs array according to current search
        let songsById = playlistSongsById.merging(songsById.wrappedValue) { (old,_) in old }.filter {
            $0.value.matches(songBookSearch.wrappedValue) != .nomatch &&
            (selectedSongBook.wrappedValue == nil || !$0.value.inPlaylist) &&
            (selectedSongBook.wrappedValue == nil || $0.value.songBook.id == selectedSongBook.wrappedValue?.id) &&
            (!filteredSongBookIds.wrappedValue.contains($0.value.songBook.id) || $0.value.inPlaylist)
        }.sorted {
            $0.value.compare(songBookSearch: songBookSearch.wrappedValue, to: $1.value, playlist: playlist.wrappedValue)
        }
        
        // Select first song
        if selectedSongId.wrappedValue == nil {
            selectedSongId.wrappedValue = songsById.first?.key
            return
        }
        
        // Actual position
        guard let index = songsById.firstIndex(where: {
            $0.key == selectedSongId.wrappedValue
        }) else {
            selectedSongId.wrappedValue = songsById.first?.key
            return
        }
        
        // Check position
        let pos = songsById.index(index, offsetBy: change)
        if pos < songsById.startIndex || pos >= songsById.endIndex { return }
        
        // Update selected song
        selectedSongId.wrappedValue = songsById[pos].key
    }
    
    // MARK: - Constants
    
    private enum Key {
        static let arrowleft: UInt16 = 123
        static let arrowright: UInt16 = 124
        static let arrowdown: UInt16 = 125
        static let arrowup: UInt16 = 126
        static let backspace: UInt16 = 51
    }
}
