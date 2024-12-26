//
//  BandRawDTO.swift
//  DTO
//
//  Created by Ondřej Wrzecionko on 10.03.2022.
//

import Foundation

/// Raw structure that does not contain `members` property due to circular dependency
struct BandRawDTO: Decodable {
    let id: Int
    let name: String
}
