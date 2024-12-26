//
//  UserRawDTO.swift
//  DTO
//
//  Created by Ondřej Wrzecionko on 10.03.2022.
//

import Foundation

/// Raw structure that does not contain `bands` property due to circular dependency
struct UserRawDTO: Decodable {
    let id: Int
    let email: String
    let name: String
}
