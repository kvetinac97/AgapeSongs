//
//  RoleDTO.swift
//  DTO
//
//  Created by Ondřej Wrzecionko on 09.03.2022.
//

import Foundation

struct RoleDTO: Decodable {
    let id: Int
    let level: RoleLevel
}

enum RoleLevel: String, Codable, Equatable, Hashable, CaseIterable {
    case LEADER = "LEADER"
    case MUSICIAN = "MUSICIAN"
    case SINGER = "SINGER"
}

extension RoleLevel {
    var displayName: String {
        switch self {
        case .LEADER:
            return NSLocalizedString("band_role_leader", comment: "")
        case .MUSICIAN:
            return NSLocalizedString("band_role_musician", comment: "")
        case .SINGER:
            return NSLocalizedString("band_role_singer", comment: "")
        }
    }
}

extension RoleLevel: Identifiable {
    var id: Int {
        switch self {
        case .LEADER:
            return 1
        case .MUSICIAN:
            return 2
        case .SINGER:
            return 3
        }
    }
}

extension RoleLevel {
    /// Gets higher level for role promoting, `nil` if current level is already highest
    func higherLevel() -> RoleLevel? {
        switch self {
        case .LEADER:
            return nil
        case .MUSICIAN:
            return .LEADER
        case .SINGER:
            return .MUSICIAN
        }
    }
    
    /// Gets lower level for role demoting, `nil` if current level is already lowest
    func lowerLevel() -> RoleLevel? {
        switch self {
        case .LEADER:
            return .MUSICIAN
        case .MUSICIAN:
            return .SINGER
        case .SINGER:
            return nil
        }
    }
}
