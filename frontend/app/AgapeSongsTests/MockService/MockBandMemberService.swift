//
//  MockBandMemberService.swift
//  AgapeSongsTests
//
//  Created by Ondřej Wrzecionko on 06.04.2022.
//

import Foundation

@testable import AgapeSongs

class MockBandMemberService: BandMemberServicing {
    init() {}
    
    var bandMemberCreateResponse: Result<BandMemberDTO, HttpStatusError>?
    private(set) var bandMemberCreateCalled = false
    var bandMemberChangeResponse: Result<Void, HttpStatusError>?
    private(set) var bandMemberChangeCalled = false
    var bandMemberDeleteResponse: Result<Void, HttpStatusError>?
    private(set) var bandMemberDeleteCalled = false

    func create(bandId: Int, member: BandMemberCreateDTO) async -> Result<BandMemberDTO, HttpStatusError> {
        bandMemberCreateCalled = true
        return bandMemberCreateResponse ?? .failure(.badtext(text: "Did not provide implementation"))
    }
    
    func change(bandId: Int, memberId: Int, role: RoleLevel) async -> Result<Void, HttpStatusError> {
        bandMemberChangeCalled = true
        return bandMemberChangeResponse ?? .failure(.badtext(text: "Did not provide implementation"))
    }
    
    func delete(bandId: Int, memberId: Int) async -> Result<Void, HttpStatusError> {
        bandMemberDeleteCalled = true
        return bandMemberDeleteResponse ?? .failure(.badtext(text: "Did not provide implementation"))
    }
}
