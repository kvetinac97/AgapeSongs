//
//  KeyEventHandling.swift
//  View (macOS)
//
//  Created by Ondřej Wrzecionko on 12.03.2022.
//

import Cocoa
import SwiftUI

/// Help class for keyboard observation
struct KeyEventHandling: NSViewRepresentable {
    
    // MARK: - Properties
    
    let songBookSearch: Binding<String>
    let selectedSongId: Binding<String?>
    let songsById: Binding<[String: Song]>
    let filteredSongBookIds: Binding<[Int]>
    let playlist: Binding<Playlist>
    let selectedSongBook: Binding<SongBook?>
    let isWindowFloating: Binding<Bool>
    
    // MARK: - NSViewRepresentable
    
    func makeNSView(context: Context) -> NSView {
        let view = KeyView()
        view.songBookSearch = songBookSearch
        view.selectedSongId = selectedSongId
        view.songsById = songsById
        view.filteredSongBookIds = filteredSongBookIds
        view.playlist = playlist
        view.selectedSongBook = selectedSongBook
        DispatchQueue.main.async {
            view.window?.makeFirstResponder(view)
            view.window?.level = isWindowFloating.wrappedValue ? .floating : .normal
        }
        return view
    }
    func updateNSView(_ nsView: NSView, context: Context) {}
}
