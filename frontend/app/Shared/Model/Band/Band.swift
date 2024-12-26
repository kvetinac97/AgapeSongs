//
//  Band.swift
//  Model
//
//  Created by Ondřej Wrzecionko on 09.03.2022.
//

import Foundation

struct Band: Identifiable, Equatable, Hashable {
    let id: Int
    let name: String
    let secret: String
    var members: [BandMember]
}

extension Band {
    var idString: String {
        String(id)
    }
    
    func canEdit(user: UserLogin?) -> Bool {
        members.contains(where: { $0.userId == user?.id && $0.role == .LEADER })
    }
}

extension Band {
    var dto: BandSaveDTO {
        .init(
            id: id,
            name: name,
            secret: secret,
            members: members.map { $0.dto }
        )
    }
}

extension BandSaveDTO {
    var domain: Band {
        .init(
            id: id,
            name: name,
            secret: secret,
            members: members.map { $0.domain }
        )
    }
}

extension BandDTO {
    var domain: Band {
        .init(
            id: id,
            name: name,
            secret: secret,
            members: members.map { $0.domain }
        )
    }
}
