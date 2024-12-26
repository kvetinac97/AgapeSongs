//
//  AppleLoginDTO.swift
//  DTO
//
//  Created by Ondřej Wrzecionko on 03.03.2022.
//

import Foundation

struct AppleLoginDTO: Encodable {
    let code: String
    let name: String?
}
