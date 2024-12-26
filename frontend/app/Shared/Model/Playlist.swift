//
//  Playlist.swift
//  Model
//
//  Created by Ondřej Wrzecionko on 18.03.2022.
//

import Foundation

/// Structure holding information about current playlist songs
struct Playlist: Equatable {
    var songs: [Song]
}

extension Playlist {
    /// Playlist will always have symbolic song book id -1
    static let id = -1
    
    var songBook: SongBook {
        get { SongBook(
            id: Playlist.id,
            band: Band(id: -1, name: "Any", secret: "", members: []),
            name: NSLocalizedString("playlist", comment: ""),
            songs: songs
        ) }
        set { songs = newValue.songs }
    }
}

extension Playlist {
    var dto: PlaylistSaveDTO {
        .init(
            songs: songs.map { $0.dto }
        )
    }
}

extension PlaylistSaveDTO {
    var domain: Playlist {
        .init(
            songs: songs.map { $0.domain.addToPlaylist() }
        )
    }
}
