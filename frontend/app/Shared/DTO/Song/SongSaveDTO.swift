//
//  SongSaveDTO.swift
//  DTO
//
//  Created by Ondřej Wrzecionko on 10.03.2022.
//

import Foundation

struct SongSaveDTO: Codable {
    let id: Int
    let songBook: SongBookSaveDTO
    let name: String
    let text: [SongLineSaveDTO]
    let key: SongKey
    let bpm: Int
    let beat: SongBeat
    let capo: Int
    let lastEdit: String
    let displayId: Int?
    let note: SongNoteSaveDTO?
    let inPlaylist: Bool
}

struct SongLineSaveDTO: Codable {
    let id: String
    let chords: String?
    let text: String
}
