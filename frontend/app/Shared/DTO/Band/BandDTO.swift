//
//  BandDTO.swift
//  DTO
//
//  Created by Ondřej Wrzecionko on 09.03.2022.
//

import Foundation

struct BandDTO: Decodable {
    let id: Int
    let name: String
    let secret: String
    let members: [BandMemberDTO]
}
