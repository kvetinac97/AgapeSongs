//
//  Song.swift
//  AgapeSongs
//
//  Created by Ondřej Wrzecionko on 17.06.2021.
//

import Foundation

/*
 * One concrete song representation
 */
struct Song : Identifiable, Codable, Equatable, Hashable {
    // Name of song
    let id: String
    // All the chords/text lines
    let lines: [String]
    
    // Real name (without P: in playlist)
    let realId: String
    // Real list (without "Playlist" in playlist)
    let realListId: Int
    
    // Position in playlist
    var listId: Int
}

struct DisplayLine: Identifiable, Hashable {
    let id: Int
    let text: String
}

extension Song {
    var displayLines: [DisplayLine] {
        lines.indices.map { DisplayLine(id: $0, text: lines[$0]) }
    }
    
    func songId(_ playlistHolder: PlaylistHolder, in list: Int = 0) -> Int {
        return playlistHolder.lists[list].songs.firstIndex { $0.id == id } ?? 0
    }
    
    static let preview = Song(id: "", lines: [], realId: "", realListId: 0, listId: 0)
}
