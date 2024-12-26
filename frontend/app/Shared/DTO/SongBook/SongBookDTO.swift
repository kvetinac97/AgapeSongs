//
//  SongBookDTO.swift
//  DTO
//
//  Created by Ondřej Wrzecionko on 10.03.2022.
//

import Foundation

struct SongBookDTO: Decodable {
    let id: Int
    let band: BandDTO
    let name: String
    let songs: [SongDTO]
}
