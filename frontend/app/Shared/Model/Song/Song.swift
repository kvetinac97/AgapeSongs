//
//  Song.swift
//  Model
//
//  Created by Ondřej Wrzecionko on 10.03.2022.
//

import Foundation

// MARK: - Entity

struct Song: Equatable {
    let songId: Int
    let songBook: SongBookRaw
    let name: String
    let text: [SongLine]
    let key: SongKey
    let bpm: Int
    let beat: SongBeat
    let capo: Int
    let lastEdit: String
    let displayId: Int?
    let note: SongNote?
    let inPlaylist: Bool
    
    func canEdit(user: UserLogin?) -> Bool {
        songBook.band.members.contains(where: { $0.userId == user?.id &&
            ($0.role == .LEADER || $0.role == .MUSICIAN) })
    }
}

// MARK: - Playlist

extension Song: Identifiable {
    /// Helper property for SwiftUI list
    var id: [Int] {
        [songId, inPlaylist ? 1 : 0]
    }
    
    /// Helper property for SwiftUI selection parameter
    var idString: String {
        return String(songId) + (inPlaylist ? ",playlist" : "")
    }
    
    /// Helper property for Song display title
    var displayName: String {
        if let displayId = displayId {
            return name + String(format: " %03d", arguments: [displayId])
        }
        return name
    }
    
    /// Helper function for adding song to playlist
    func addToPlaylist() -> Song {
        .init(
            songId: songId,
            songBook: songBook,
            name: name,
            text: text,
            key: key,
            bpm: bpm,
            beat: beat,
            capo: capo,
            lastEdit: lastEdit,
            displayId: displayId,
            note: note,
            inPlaylist: true // added
        )
    }
    
    /// Helper function for editing song (getting its version not in playlist)
    func removeFromPlaylist() -> Song {
        .init(
            songId: songId,
            songBook: songBook,
            name: name,
            text: text,
            key: key,
            bpm: bpm,
            beat: beat,
            capo: capo,
            lastEdit: lastEdit,
            displayId: displayId,
            note: note,
            inPlaylist: false // removed
        )
    }
    
    /// Helper constant
    static let notInPlaylist = -1
}

// MARK: - Ordering

extension Song {
    
    /// Determines how much song is matched to searched phrase
    func matches(_ searched: String) -> SearchPriority {
        if searched.isEmpty {
            return .matchempty
        }
        if let displayId = displayId, let num = Int(searched), displayId == num {
            return .matchid
        }
        if name.lowercased().contains(searched.lowercased()) {
            return .matchnameexact
        }
        if name.trimmed().contains(searched.trimmed()) {
            return .matchname
        }
        if text.contains(where: { $0.text.lowercased().contains(searched.lowercased()) }) {
            return .matchtextexact
        }
        if text.contains(where: { $0.text.trimmed().contains(searched.trimmed()) }) {
            return .matchtext
        }
        return .nomatch
    }
    
    /// Compare function based on searched text
    func compare(songBookSearch: String, to song: Song, playlist: Playlist) -> Bool {
        // Playlist song vs normal song
        if inPlaylist != song.inPlaylist {
            return inPlaylist
        }
        
        // Playlist songs
        // this way is not efficient, however it must be used due to SwiftUI limitations
        // as there won't be more than dozens of songs, it should not matter
        if let playlistIndex = playlist.songs.firstIndex(of: self),
           let songPlaylistIndex = playlist.songs.firstIndex(of: song) {
            return playlistIndex < songPlaylistIndex
        }
        
        // Normal songs
        if songBook.name != song.songBook.name {
            return songBook.name < song.songBook.name
        }
        
        let selfMatch = matches(songBookSearch), songMatch = song.matches(songBookSearch)
        if selfMatch == songMatch {
            return name.localizedCompare(song.name) == .orderedAscending
        }
        return selfMatch < songMatch
    }
    
    /// Determines level of exactness of match
    enum SearchPriority: Comparable {
        case matchempty
        case matchid
        case matchnameexact
        case matchname
        case matchtextexact
        case matchtext
        case nomatch
    }
}

extension String {
    func trimmed() -> String {
        folding(options: .diacriticInsensitive, locale: .current).lowercased()
    }
}

extension Song {
    var dto: SongSaveDTO {
        .init(
            id: songId,
            songBook: songBook.dto,
            name: name,
            text: text.map { $0.dto },
            key: key,
            bpm: bpm,
            beat: beat,
            capo: capo,
            lastEdit: lastEdit,
            displayId: displayId,
            note: note?.dto,
            inPlaylist: inPlaylist
        )
    }
}

extension SongSaveDTO {
    var domain: Song {
        .init(
            songId: id,
            songBook: songBook.domain,
            name: name,
            text: text.map { $0.domain },
            key: key,
            bpm: bpm,
            beat: beat,
            capo: capo,
            lastEdit: lastEdit,
            displayId: displayId,
            note: note?.domain,
            inPlaylist: inPlaylist
        )
    }
}

extension SongDTO {
    var domain: Song {
        .init(
            songId: id,
            songBook: songBook.domain,
            name: name,
            text: text.map { $0.domain },
            key: key,
            bpm: bpm,
            beat: beat,
            capo: capo,
            lastEdit: lastEdit,
            displayId: displayId,
            note: note?.domain,
            inPlaylist: false
        )
    }
}
