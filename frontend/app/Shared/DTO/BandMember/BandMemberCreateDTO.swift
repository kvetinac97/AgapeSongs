//
//  BandMemberCreateDTO.swift
//  DTO
//
//  Created by Ondřej Wrzecionko on 01.04.2022.
//

import Foundation

struct BandMemberCreateDTO: Encodable {
    let email: String
    let name: String
    let roleId: Int
}
