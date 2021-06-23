//
//  Playlist.swift
//  AgapeSongs
//
//  Created by Ondřej Wrzecionko on 17.06.2021.
//

import Foundation

/*
 * One playlist representable
 */
struct Playlist : Identifiable, Codable {
    // Name of the playlist
    let id: String
    // Songs in playlist
    var songs: [Song]
}
