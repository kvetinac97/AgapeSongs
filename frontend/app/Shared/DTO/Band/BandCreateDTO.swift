//
//  BandCreateDTO.swift
//  AgapeSongs
//
//  Created by Ondřej Wrzecionko on 01.05.2023.
//

import Foundation

struct BandCreateDTO: Encodable {
    let name: String
    let secret: String
}
