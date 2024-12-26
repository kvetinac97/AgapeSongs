//
//  SongBookSaveDTO.swift
//  DTO
//
//  Created by Ondřej Wrzecionko on 10.03.2022.
//

import Foundation

struct SongBookSaveDTO: Codable {
    let id: Int
    let name: String
    let band: BandSaveDTO
}
