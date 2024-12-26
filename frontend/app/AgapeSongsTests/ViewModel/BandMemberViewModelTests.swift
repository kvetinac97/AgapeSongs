//
//  BandMemberViewModelTests.swift
//  AgapeSongsTests
//
//  Created by Ondřej Wrzecionko on 06.04.2022.
//

import SwiftUI
import XCTest

@testable import AgapeSongs

final class BandMemberViewModelTests: AgapeSongsTestCase {
    
    private struct DI: HasAppState & HasBandMemberService {
        let appState: AppState
        let bandMemberService: BandMemberServicing
    }
    
    private static let dummyBand = Band(id: 1, name: "", secret: "", members: [])
    private var wrappedBand: Band = dummyBand
    private var band: Binding<Band> = .constant(dummyBand)
    private let dummyBandMember = BandMemberDTO(
        id: 1,
        band: BandRawDTO(id: 1, name: ""),
        user: UserRawDTO(id: 1, email: "", name: ""),
        role: RoleDTO(id: 1, level: RoleLevel.LEADER)
    )
    
    private var bandMemberService: MockBandMemberService!
    private var viewModel: BandViewModel!
    
    override func setUp() {
        super.setUp()
        bandMemberService = .init()
        setUpViewModel()
    }
    
    override func tearDown() {
        bandMemberService = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testBandMemberCreateSuccess() async {
        bandMemberService.bandMemberCreateResponse = .success(dummyBandMember)
        
        await viewModel.create()
        
        XCTAssertEqual(viewModel.bandMemberAlertText, NSLocalizedString("band_member_create_success", comment: ""))
        XCTAssertEqual(band.wrappedValue.members, [dummyBandMember.domain])
    }
    
    func testBandMemberCreateFailure() async {
        bandMemberService.bandMemberCreateResponse = .failure(.badtext(text: "Mock error"))
        
        await viewModel.create()
        
        XCTAssertEqual(viewModel.bandMemberAlertText, NSLocalizedString("band_member_create_failure", comment: "") + "Mock error")
        XCTAssertEqual(band.wrappedValue.members, [])
    }
    
    func testBandMemberChangeSuccess() async {
        bandMemberService.bandMemberChangeResponse = .success(())
        band.wrappedValue.members = [dummyBandMember.domain]
        
        await viewModel.change(member: dummyBandMember.domain, role: RoleLevel.MUSICIAN)
        
        let bandMembers = [BandMember(
            id: dummyBandMember.id,
            name: dummyBandMember.user.name,
            userId: dummyBandMember.user.id,
            role: RoleLevel.MUSICIAN
        )]
        
        XCTAssertEqual(viewModel.bandMemberAlertText, NSLocalizedString("band_member_change_role_success", comment: ""))
        XCTAssertEqual(band.wrappedValue.members, bandMembers)
    }
    
    func testBandMemberChangeFailure() async {
        bandMemberService.bandMemberChangeResponse = .failure(.badtext(text: "Mock error"))
        band.wrappedValue.members = [dummyBandMember.domain]
        
        await viewModel.change(member: dummyBandMember.domain, role: RoleLevel.MUSICIAN)
        
        XCTAssertEqual(viewModel.bandMemberAlertText, NSLocalizedString("band_member_change_role_failure", comment: "") + "Mock error")
        XCTAssertEqual(band.wrappedValue.members, [dummyBandMember.domain])
    }
    
    func testBandMemberDeleteSelfSuccess() async {
        bandMemberService.bandMemberDeleteResponse = .success(())
        appState.login(user: UserLogin(id: dummyBandMember.user.id, loginSecret: "", email: "", name: ""))
        
        await viewModel.delete(member: dummyBandMember.domain)
        
        XCTAssertEqual(appState.user, nil)
    }
    
    func testBandMemberDeleteSuccess() async {
        bandMemberService.bandMemberDeleteResponse = .success(())
        band.wrappedValue.members = [dummyBandMember.domain]
        
        await viewModel.delete(member: dummyBandMember.domain)
        
        XCTAssertEqual(viewModel.bandMemberAlertText, NSLocalizedString("band_member_delete_success", comment: ""))
        XCTAssertEqual(band.wrappedValue.members, [])
    }
    
    func testBandMemberDeleteFailure() async {
        bandMemberService.bandMemberDeleteResponse = .failure(.badtext(text: "Mock error"))
        band.wrappedValue.members = [dummyBandMember.domain]
        let user = UserLogin(id: dummyBandMember.user.id, loginSecret: "", email: "", name: "")
        appState.login(user: user)
        
        await viewModel.delete(member: dummyBandMember.domain)
        
        XCTAssertEqual(viewModel.bandMemberAlertText, NSLocalizedString("band_member_delete_failure", comment: "") + "Mock error")
        XCTAssertEqual(band.wrappedValue.members, [dummyBandMember.domain])
        XCTAssertEqual(appState.user, user)
    }
    
    // MARK: - Private helpers
    
    private func setUpViewModel() {
        band = Binding<Band>(
            get: { [weak self] in self?.wrappedBand ?? BandMemberViewModelTests.dummyBand },
            set: { [weak self] in self?.wrappedBand = $0 }
        )
        viewModel = BandViewModel(
            band: band,
            context: DI(
                appState: appState,
                bandMemberService: bandMemberService
            )
        )
    }
}
