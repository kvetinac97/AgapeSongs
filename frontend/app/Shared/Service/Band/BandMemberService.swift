//
//  BandMemberService.swift
//  Service
//
//  Created by Ondřej Wrzecionko on 01.04.2022.
//

import Foundation

/// Protocol for BandMember service
protocol BandMemberServicing {
    /// Creates a new band member with musician role, given name and e-mail
    func create(bandId: Int, member: BandMemberCreateDTO) async -> Result<BandMemberDTO, HttpStatusError>
    
    /// Changes role of band member with given ID
    func change(bandId: Int, memberId: Int, role: RoleLevel) async -> Result<Void, HttpStatusError>
    
    /// Deletes band member with given ID
    func delete(bandId: Int, memberId: Int) async -> Result<Void, HttpStatusError>
}

/// Helper DI protocol
protocol HasBandMemberService {
    var bandMemberService: BandMemberServicing { get }
}

struct BandMemberService: BandMemberServicing {
    
    // MARK: - Private properties
    
    private let networkService: NetworkServicing
    
    // MARK: - Init
    
    init(context: HasNetworkService) {
        networkService = context.networkService
    }
    
    // MARK: - Interface method implementation
    
    func create(bandId: Int, member: BandMemberCreateDTO) async -> Result<BandMemberDTO, HttpStatusError> {
        let response = await networkService.post(
            url: Constants.bandListUrl + "/" + String(bandId) + "/members",
            body: member
        )
        switch response {
        case .success(let data):
            guard let bandMember = try? JSONDecoder().decode(BandMemberDTO.self, from: data) else {
                return .failure(.badtext(text: "band_member_response_parse_error"))
            }
            return .success(bandMember)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func change(bandId: Int, memberId: Int, role: RoleLevel) async -> Result<Void, HttpStatusError> {
        let response = await networkService.patch(
            url: Constants.bandListUrl + "/" + String(bandId) + "/members/" + String(memberId),
            body: BandMemberUpdateDTO(roleId: role.id)
        )
        return response.map { _ in }
    }
    
    func delete(bandId: Int, memberId: Int) async -> Result<Void, HttpStatusError> {
        let response = await networkService.delete(
            url: Constants.bandListUrl + "/" + String(bandId) + "/members/" + String(memberId)
        )
        return response.map { _ in }
    }
    
    // MARK: - Constants
    
    private enum Constants {
        static let bandListUrl = "/band"
    }
}

// Implementation for DI
private let _bandMemberService = BandMemberService(context: context)

extension DI: HasBandMemberService {
    var bandMemberService: BandMemberServicing { _bandMemberService }
}
