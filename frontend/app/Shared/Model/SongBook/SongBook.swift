//
//  SongBook.swift
//  Model
//
//  Created by Ondřej Wrzecionko on 10.03.2022.
//

import Foundation

struct SongBook: Identifiable, Equatable {
    let id: Int
    let band: Band
    let name: String
    var songs: [Song]
}

extension SongBook {
    static var preview: SongBook {
        .init(
            id: 1,
            band: Band(id: 1, name: "Jošafat", secret: "", members: []),
            name: "Jošafat",
            songs: []
        )
    }
    
    var idString: String {
        .init(id)
    }
    
    func canEdit(user: UserLogin?) -> Bool {
        band.members.contains(where: { $0.userId == user?.id &&
            ($0.role == .LEADER || $0.role == .MUSICIAN) })
    }
}

extension SongBookDTO {
    var domain: SongBook {
        .init(
            id: id,
            band: band.domain,
            name: name,
            songs: songs.map { $0.domain }
        )
    }
}
