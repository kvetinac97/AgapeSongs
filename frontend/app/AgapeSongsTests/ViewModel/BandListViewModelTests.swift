//
//  BandListViewModelTests.swift
//  AgapeSongsTests
//
//  Created by Ondřej Wrzecionko on 09.03.2022.
//

import Foundation
import XCTest

@testable import AgapeSongs

final class BandListViewModelTests: AgapeSongsTestCase {
    
    private struct DI: HasAppState & HasBandService & HasUserService {
        let appState: AppState
        let bandService: BandServicing
        let userService: UserServicing
    }
    
    private var viewModel: BandListViewModel!
    
    override func setUp() {
        super.setUp()
        setUpViewModel()
    }
    
    // MARK: - Tests
    
    func testLoadBandsSuccess() async {
        let mockBandResponse = [
            BandDTO(id: 1, name: "Jošafat", secret: "", members: []),
            BandDTO(id: 2, name: "Agapebend", secret: "", members: [])
        ]
        bandService.bandListResponse = .success(mockBandResponse)
        
        await viewModel.loadBands()
        
        XCTAssertTrue(bandService.bandListCalled)
        XCTAssertEqual(viewModel.bands, mockBandResponse.map { $0.domain })
        XCTAssertEqual(viewModel.state, .success)
    }
    
    func testLoadBandsEmpty() async {
        bandService.bandListResponse = .success([BandDTO]())
        
        await viewModel.loadBands()
        
        XCTAssertTrue(bandService.bandListCalled)
        XCTAssertEqual(viewModel.bands, [Band]())
        XCTAssertEqual(viewModel.state, .empty)
    }
    
    func testLoadBandsFailure() async {
        bandService.bandListResponse = .failure(.badtext(text: "Mock error"))
        
        await viewModel.loadBands()
        
        XCTAssertTrue(bandService.bandListCalled)
        XCTAssertEqual(viewModel.bands, [Band]())
        XCTAssertEqual(viewModel.state, .failure("Mock error"))
    }
    
    func testDeleteUserSuccess() async {
        appState.login(user: UserLogin(id: 1, loginSecret: "test", email: "test@test.cz", name: "Test"))
        userService.deleteResponse = .success(Void())
        
        await viewModel.deleteUser()
        
        XCTAssertEqual(appState.user, nil)
    }
    
    func testDeleteUserFailure() async {
        let user = UserLogin(id: 1, loginSecret: "test", email: "test@test.cz", name: "Test")
        appState.login(user: user)
        userService.deleteResponse = .failure(.badtext(text: "Mock error"))
        
        await viewModel.deleteUser()
        
        XCTAssertEqual(appState.user, user)
        XCTAssertEqual(viewModel.state, .failure("Mock error"))
    }
    
    // MARK: - Private helpers
    
    private func setUpViewModel() {
        viewModel = BandListViewModel(
            context: DI(
                appState: appState,
                bandService: bandService,
                userService: userService
            )
        )
    }
}
