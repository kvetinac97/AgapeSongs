//
//  BandMemberSaveDTO.swift
//  DTO
//
//  Created by Ondřej Wrzecionko on 09.03.2022.
//

import Foundation

struct BandMemberSaveDTO: Codable {
    let id: Int
    let name: String
    let userId: Int
    let role: RoleLevel
}
