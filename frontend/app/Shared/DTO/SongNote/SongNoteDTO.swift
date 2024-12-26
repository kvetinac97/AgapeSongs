//
//  SongNoteDTO.swift
//  DTO
//
//  Created by Ondřej Wrzecionko on 10.03.2022.
//

import Foundation

struct SongNoteDTO: Decodable {
    let id: Int
    let notes: String
    let capo: Int
    let lastEdit: String
}
