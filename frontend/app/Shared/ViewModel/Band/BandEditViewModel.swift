//
//  BandEditViewModel.swift
//  AgapeSongs
//
//  Created by Ondřej Wrzecionko on 01.05.2023.
//

import Foundation

final class BandEditViewModel: ObservableObject {
    
    // MARK: - Public properties
        
    @Published var editBandModel: EditModel<Band>
    @Published var bandName: String = ""
    @Published var bandSecret: String = ""
    
    @Published var loading: Bool = false
    @Published var isBandAlertDisplayed: Bool = false
    @Published var bandAlertText: String = "" {
        didSet {
            isBandAlertDisplayed = !bandAlertText.isEmpty
        }
    }
    
    // MARK: - Private properties
    
    private let bandListViewModel: BandListViewModel
    private let bandService: BandServicing
    
    init(
        context: HasBandService,
        bandListViewModel: BandListViewModel,
        editBandModel: EditModel<Band>
    ) {
        self.bandListViewModel = bandListViewModel
        self.bandService = context.bandService
        self.editBandModel = editBandModel

        if case .edit(let band) = editBandModel {
            bandName = band.name
            bandSecret = band.secret
        }
    }
    
    // MARK: - Public methods
    
    /// Simple function to check for validity
    func isValid() -> Bool {
        !bandName.isEmpty && !bandSecret.isEmpty
    }
    
    func submit() {
        if !isValid() {
            return
        }
        
        loading = true
        Task {
            switch editBandModel {
            case .create:
                await create()
            case .edit(let band):
                await change(bandId: band.id)
            }
        }
    }
    
    func create() async {
        let dto = BandCreateDTO(name: bandName, secret: bandSecret)
        let result = await bandService.create(band: dto)
        await create(result: result)
    }
    
    func change(bandId: Int) async {
        let dto = BandUpdateDTO(name: bandName, secret: bandSecret)
        let result = await bandService.change(bandId: bandId, band: dto)
        await change(result: result)
    }
    
    // MARK: - Private methods
    
    @MainActor
    private func create(result: Result<BandDTO, HttpStatusError>) async {
        switch result {
        case .success(let band):
            bandListViewModel.bands.append(band.domain)
            bandAlertText = NSLocalizedString("band_create_join_success", comment: "")
        case .failure(let error):
            bandAlertText = NSLocalizedString("band_create_join_failure", comment: "") + error.errorDescription
        }
        
        // Clear data
        bandName = ""
        bandSecret = ""
    }
    
    @MainActor
    private func change(result: Result<BandDTO, HttpStatusError>) async {
        switch result {
        case .success(let dto):
            let band = dto.domain
            if let index = bandListViewModel.bands.firstIndex(where: { $0.id == band.id }) {
                bandListViewModel.bands[index] = band
            }
            bandAlertText = NSLocalizedString("band_edit_success", comment: "")
        case .failure(let error):
            bandAlertText = NSLocalizedString("band_edit_failure", comment: "") + error.errorDescription
        }
    }
}
