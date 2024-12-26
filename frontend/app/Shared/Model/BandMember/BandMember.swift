//
//  BandMember.swift
//  Band
//
//  Created by Ondřej Wrzecionko on 09.03.2022.
//

import Foundation

struct BandMember: Equatable, Identifiable, Hashable {
    let id: Int
    let name: String
    let userId: Int
    var role: RoleLevel
}

extension BandMember {
    var dto: BandMemberSaveDTO {
        .init(
            id: id,
            name: name,
            userId: userId,
            role: role
        )
    }
}

extension BandMemberSaveDTO {
    var domain: BandMember {
        .init(
            id: id,
            name: name,
            userId: userId,
            role: role
        )
    }
}

extension BandMemberDTO {
    var domain: BandMember {
        .init(
            id: id,
            name: user.name,
            userId: user.id,
            role: role.level
        )
    }
}
