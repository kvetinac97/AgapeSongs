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
struct Song : Identifiable, Codable, Equatable {
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
    var songId = 0
}
