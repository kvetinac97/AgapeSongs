//
//  BandMemberDTO.swift
//  DTO
//
//  Created by Ondřej Wrzecionko on 09.03.2022.
//

import Foundation

struct BandMemberDTO: Decodable {
    let id: Int
    let band: BandRawDTO
    let user: UserRawDTO
    let role: RoleDTO
}
