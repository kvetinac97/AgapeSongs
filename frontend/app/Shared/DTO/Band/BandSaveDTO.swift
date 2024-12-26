//
//  BandSaveDTO.swift
//  DTO
//
//  Created by Ondřej Wrzecionko on 09.03.2022.
//

import Foundation

struct BandSaveDTO: Codable {
    let id: Int
    let name: String
    let secret: String
    let members: [BandMemberSaveDTO]
}
