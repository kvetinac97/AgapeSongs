//
//  SongNote.swift
//  Model
//
//  Created by Ondřej Wrzecionko on 10.03.2022.
//

import Foundation

struct SongNote: Equatable {
    let id: Int
    let notes: String
    let capo: Int
    let lastEdit: String
}

extension SongNote {
    var dto: SongNoteSaveDTO {
        .init(
            id: id,
            notes: notes,
            capo: capo,
            lastEdit: lastEdit
        )
    }
}

extension SongNoteSaveDTO {
    var domain: SongNote {
        .init(
            id: id,
            notes: notes,
            capo: capo,
            lastEdit: lastEdit
        )
    }
}

extension SongNoteDTO {
    var domain: SongNote {
        .init(
            id: id,
            notes: notes,
            capo: capo,
            lastEdit: lastEdit
        )
    }
}
