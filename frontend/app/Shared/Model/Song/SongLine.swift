//
//  SongLine.swift
//  Model
//
//  Created by Ondřej Wrzecionko on 23.03.2022.
//

import Foundation

/// One line is represented as text and optional chords
struct SongLine: Equatable {
    let id: String
    let chords: String?
    let text: String
}

extension SongLine {
    var dto: SongLineSaveDTO {
        .init(
            id: id,
            chords: chords,
            text: text
        )
    }
}

extension SongLineDTO {
    var domain: SongLine {
        .init(
            id: id,
            chords: chords,
            text: text
        )
    }
}

extension SongLineSaveDTO {
    var domain: SongLine {
        .init(
            id: id,
            chords: chords,
            text: text
        )
    }
}
