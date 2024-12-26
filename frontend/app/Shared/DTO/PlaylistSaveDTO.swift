//
//  PlaylistSaveDTO.swift
//  DTO
//
//  Created by Ondřej Wrzecionko on 20.03.2022.
//

import Foundation

struct PlaylistSaveDTO: Codable {
    let songs: [SongSaveDTO]
}
