//
//  SongBookRaw.swift
//  Model
//
//  Created by Ondřej Wrzecionko on 10.03.2022.
//

import Foundation

/// Raw structure that does not contain `songs` property due to circular dependency
struct SongBookRaw: Equatable {
    let id: Int
    let name: String
    let band: Band
}

extension SongBookRaw {
    var dto: SongBookSaveDTO {
        .init(
            id: id,
            name: name,
            band: band.dto
        )
    }
}

extension SongBookSaveDTO {
    var domain: SongBookRaw {
        .init(
            id: id,
            name: name,
            band: band.domain
        )
    }
}

extension SongBookRawDTO {
    var domain: SongBookRaw {
        .init(
            id: id,
            name: name,
            band: band.domain
        )
    }
}
