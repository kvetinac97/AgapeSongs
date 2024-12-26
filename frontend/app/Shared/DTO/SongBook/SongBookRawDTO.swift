//
//  SongBookRawDTO.swift
//  DTO
//
//  Created by Ondřej Wrzecionko on 10.03.2022.
//

import Foundation

/// Raw structure that does not contain `songs` property due to circular dependency
struct SongBookRawDTO: Decodable {
    let id: Int
    let name: String
    let band: BandDTO
}
