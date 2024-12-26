//
//  UserDTO.swift
//  DTO
//
//  Created by Ondřej Wrzecionko on 09.03.2022.
//

import Foundation

struct UserDTO: Decodable {
    let id: Int
    let email: String
    let name: String
    let bands: [BandMemberDTO]
}
