//
//  MockBandService.swift
//  AgapeSongsTests
//
//  Created by Ondřej Wrzecionko on 09.03.2022.
//

import Foundation

@testable import AgapeSongs

class MockBandService: BandServicing {
    init() {}
    
    var selectedBand: BandSaveDTO? = nil
    
    var bandListResponse: Result<[BandDTO], HttpStatusError>?
    private(set) var bandListCalled = false
    
    var bandCreateResponse: Result<BandDTO, HttpStatusError>?
    private(set) var bandCreateCalled = false
    
    var bandChangeResponse: Result<BandDTO, HttpStatusError>?
    private(set) var bandChangeCalled = false
    
    func bandList() async -> Result<[BandDTO], HttpStatusError> {
        bandListCalled = true
        return bandListResponse ?? .failure(.badtext(text: "Did not provide implementation"))
    }
    
    func select(band: BandSaveDTO) {
        selectedBand = band
    }
    
    func clearBand() {
        selectedBand = nil
    }
    
    func create(band: BandCreateDTO) async -> Result<BandDTO, HttpStatusError> {
        bandCreateCalled = true
        return bandCreateResponse ?? .failure(.badtext(text: "Did not provide implementation"))
    }
    
    func change(bandId: Int, band: BandUpdateDTO) async -> Result<BandDTO, HttpStatusError> {
        bandChangeCalled = true
        return bandChangeResponse ?? .failure(.badtext(text: "Did not provide implementation"))
    }
}
