//
//  KeyEventHandling.swift
//  AgapeSongs
//
//  Created by Ondřej Wrzecionko on 17.06.2021.
//

import Cocoa
import SwiftUI

/*
 * Help class serving for keyboard observation
 */
struct KeyEventHandling : NSViewRepresentable {
    
    // Help properties
    var text: Binding<String>
    var selection: Binding<Song?>
    var lists: Binding<[Playlist]>
    
    class KeyView: NSView {
        
        // We keep track of search text, selected song and all playlists & songs
        var text: Binding<String> = .constant("")
        var selection: Binding<Song?> = .constant(nil)
        var lists : Binding<[Playlist]> = .constant([Playlist]())

        override var acceptsFirstResponder: Bool { true }

        override func keyDown (with event: NSEvent) {
            
            // Move on key up / key down
            if (event.keyCode == 125 || event.keyCode == 126) && text.wrappedValue.isEmpty {
                // Select first item
                if selection.wrappedValue == nil {
                    selection.wrappedValue = lists.wrappedValue[1].songs[0]
                    return
                }
                
                let actualListId = selection.wrappedValue!.listId
                let actualSongId = selection.wrappedValue!.songId
                let newSongId = actualSongId + (event.keyCode == 125 ? 1 : -1)
                
                // We need to switch playlist
                if newSongId == lists.wrappedValue[actualListId].songs.endIndex || newSongId < 0 {
                    let newListId = actualListId + (event.keyCode == 125 ? 1 : -1)
                    if newListId == lists.wrappedValue.endIndex || newListId < 0 {
                        return
                    }
                    let newerSongId = (event.keyCode == 125 ? 0 : lists.wrappedValue[newListId].songs.endIndex - 1)
                    if lists.wrappedValue[newListId].songs.isEmpty {
                        return
                    }
                    selection.wrappedValue = lists.wrappedValue[newListId].songs[newerSongId]
                    return
                }
                
                // Just change inside of playlist
                selection.wrappedValue = lists.wrappedValue[actualListId].songs[newSongId]
            }
            
            // Backspace
            if event.keyCode == 51 && !text.wrappedValue.isEmpty {
                text.wrappedValue.removeLast()
            }
            // Classic key
            else if !event.modifierFlags.contains(.command) {
                text.wrappedValue += (event.characters?.filter({$0.isLetter || $0.isNumber || $0.isPunctuation || $0 == " "}) ?? "")
            }
        }
    }

    func makeNSView(context: Context) -> NSView {
        let view = KeyView()
        view.text = text
        view.selection = selection
        view.lists = lists
        DispatchQueue.main.async {
            view.window?.makeFirstResponder(view)
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}

}
