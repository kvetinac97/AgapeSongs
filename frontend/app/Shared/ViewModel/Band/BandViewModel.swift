//
//  BandViewModel.swift
//  ViewModel
//
//  Created by Ondřej Wrzecionko on 01.04.2022.
//

import CoreImage.CIFilterBuiltins
import SwiftUI

final class BandViewModel: ObservableObject {
    
    // MARK: - Published properties
    
    @Published var editMode: Bool = false
    @Published var band: Binding<Band>
    
    @Published var isCreateMemberDisplayed: Bool = false
    @Published var memberName: String = ""
    @Published var memberEmail: String = ""
    @Published var memberRole: RoleLevel = .MUSICIAN
    
    @Published var loading: Bool = false
    @Published var isBandMemberAlertDisplayed: Bool = false
    @Published var bandMemberAlertText: String = "" {
        didSet {
            isBandMemberAlertDisplayed = !bandMemberAlertText.isEmpty
        }
    }
    
    @Published var isBandHidden: Bool {
        didSet {
            bandService.hide(band: band.wrappedValue, hidden: isBandHidden)
        }
    }
    
    #if os(macOS)
    @Published var bandJoinQRImage: NSImage? = nil
    #else
    @Published var bandJoinQRImage: UIImage? = nil
    #endif
    
    // MARK: - Private properties
    
    private let appState: AppState
    private let bandService: BandServicing
    private let bandMemberService: BandMemberServicing
    
    // MARK: - Init
    
    init(band: Binding<Band>, context: HasAppState & HasBandService & HasBandMemberService) {
        self.band = band
        appState = context.appState
        bandService = context.bandService
        bandMemberService = context.bandMemberService
        
        isBandHidden = bandService.getHiddenBandIds().contains(band.wrappedValue.id)
        generateQRCode()
    }
    
    // MARK: - Public methods
        
    /// Simple function to check for validity
    func isValid() -> Bool {
        !memberName.isEmpty && !memberEmail.isEmpty
    }
    
    func create() {
        if !isValid() {
            return
        }
        
        let band = band.wrappedValue
        loading = true
        Task { await create(band: band) }
    }
    func create(band: Band) async {
        let dto = BandMemberCreateDTO(email: memberEmail, name: memberName, roleId: memberRole.id)
        let result = await bandMemberService.create(bandId: band.id, member: dto)
        await create(result: result)
    }
    
    func change(member: BandMember, role: RoleLevel) {
        loading = true
        Task { await change(member: member, role: role) }
    }
    func change(member: BandMember, role: RoleLevel) async {
        let result = await bandMemberService.change(
            bandId: band.wrappedValue.id,
            memberId: member.id,
            role: role
        )
        await change(member: member, role: role, result: result)
    }
    
    func delete(member: BandMember) {
        loading = true
        let band = band.wrappedValue
        Task { await delete(band: band, member: member) }
    }
    func delete(band: Band, member: BandMember) async {
        let result = await bandMemberService.delete(
            bandId: band.id,
            memberId: member.id
        )
        await delete(member: member, result: result)
    }
    
    // MARK: - Private methods
    
    @MainActor
    private func create(result: Result<BandMemberDTO, HttpStatusError>) async {
        switch result {
        case .success(let bandMember):
            band.wrappedValue.members.append(bandMember.domain)
            bandMemberAlertText = NSLocalizedString("band_member_create_success", comment: "")
        case .failure(let error):
            bandMemberAlertText = NSLocalizedString("band_member_create_failure", comment: "") + error.errorDescription
        }
        
        // Clear data
        memberName = ""
        memberEmail = ""
        memberRole = .MUSICIAN
    }
    
    @MainActor
    private func change(member: BandMember, role: RoleLevel, result: Result<Void, HttpStatusError>) async {
        switch result {
        case .success(_):
            if let index = band.wrappedValue.members.firstIndex(where: { $0.id == member.id }) {
                band.wrappedValue.members[index].role = role
            }
            bandMemberAlertText = NSLocalizedString("band_member_change_role_success", comment: "")
        case .failure(let error):
            bandMemberAlertText = NSLocalizedString("band_member_change_role_failure", comment: "") + error.errorDescription
        }
    }
    
    @MainActor
    private func delete(member: BandMember, result: Result<Void, HttpStatusError>) async {
        switch result {
        case .success(_):
            // If deleted itself, logout user
            if member.userId == appState.user?.id {
                appState.logout()
                return
            }
            band.wrappedValue.members.removeAll(where: { $0.id == member.id })
            bandMemberAlertText = NSLocalizedString("band_member_delete_success", comment: "")
        case .failure(let error):
            bandMemberAlertText = NSLocalizedString("band_member_delete_failure", comment: "") + error.errorDescription
        }
    }
    
    private func generateQRCode() {
        // User must be user in order to generate QR code
        guard band.wrappedValue.members.first(where: { member in
            member.userId == appState.user?.id && member.role == .LEADER
        }) != nil else { return }
        
        let urlString = "agapesongs://join/\(band.wrappedValue.id)?secret=\(band.wrappedValue.secret)"
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        
        let data = urlString.data(using: .ascii)
        filter.message = data!
        filter.correctionLevel = "H"

        if let outputImage = filter.outputImage {
            if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                #if os(macOS)
                bandJoinQRImage = NSImage(cgImage: cgImage, size: NSSize(width: 200, height: 200))
                #else
                bandJoinQRImage = UIImage(cgImage: cgImage)
                #endif
            }
        }
    }
}
