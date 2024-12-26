//
//  UserLoginDTO.swift
//  DTO
//
//  Created by Ondřej Wrzecionko on 03.03.2022.
//

import Foundation

struct UserLoginDTO: Codable, Equatable {
    let id: Int
    let loginSecret: String
    let email: String
    let name: String
}
