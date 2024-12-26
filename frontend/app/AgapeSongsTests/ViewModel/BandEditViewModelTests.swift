//
//  BandEditViewModelTests.swift
//  AgapeSongsTests
//
//  Created by Ondřej Wrzecionko on 04.06.2023.
//

import SwiftUI
import XCTest

@testable import AgapeSongs

final class BandEditViewModelTests: AgapeSongsTestCase {
    
    private struct DI: HasAppState & HasBandService & HasUserService {
        let appState: AppState
        let bandService: BandServicing
        let userService: UserServicing
    }
    
    private let dummyBand = BandDTO(id: 1, name: "", secret: "", members: [])
    private let dummyBand2 = BandDTO(id: 1, name: "Another", secret: "xyz", members: [])
    
    private var listViewModel: BandListViewModel!
    private var viewModel: BandEditViewModel!
    
    override func setUp() {
        super.setUp()
        bandService = .init()
        setUpViewModel()
    }
    
    override func tearDown() {
        bandService = nil
        listViewModel = nil
        viewModel = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testBandCreateSuccess() async {
        bandService.bandCreateResponse = .success(dummyBand)
        
        await viewModel.create()
        
        XCTAssertEqual(viewModel.bandAlertText, NSLocalizedString("band_create_join_success", comment: ""))
        XCTAssertEqual(listViewModel.bands, [dummyBand.domain])
    }
    
    func testBandMemberCreateFailure() async {
        bandService.bandCreateResponse = .failure(.badtext(text: "Mock error"))
        
        await viewModel.create()
        
        XCTAssertEqual(viewModel.bandAlertText, NSLocalizedString("band_create_join_failure", comment: "") + "Mock error")
        XCTAssertEqual(listViewModel.bands, [])
    }
    
    func testBandMemberChangeSuccess() async {
        bandService.bandChangeResponse = .success(dummyBand2)
        listViewModel.bands = [dummyBand.domain]
        
        await viewModel.change(bandId: dummyBand.id)
        
        XCTAssertEqual(viewModel.bandAlertText, NSLocalizedString("band_edit_success", comment: ""))
        XCTAssertEqual(listViewModel.bands, [dummyBand2.domain])
    }
    
    func testBandMemberChangeFailure() async {
        bandService.bandChangeResponse = .failure(.badtext(text: "Mock error"))
        listViewModel.bands = [dummyBand.domain]
        
        await viewModel.change(bandId: dummyBand.id)
        
        XCTAssertEqual(viewModel.bandAlertText, NSLocalizedString("band_edit_failure", comment: "") + "Mock error")
        XCTAssertEqual(listViewModel.bands, [dummyBand.domain])
    }
    
    // MARK: - Private helpers
    
    private func setUpViewModel() {
        let di = DI(appState: appState, bandService: bandService, userService: userService)
        listViewModel = BandListViewModel(context: di)
        viewModel = BandEditViewModel(
            context: di,
            bandListViewModel: listViewModel,
            editBandModel: .create
        )
    }
}
