//
//  BandListInnerView.swift
//  View
//
//  Created by Ondřej Wrzecionko on 14.03.2022.
//

import SwiftUI

struct BandListInnerView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var appState: AppState
    @ObservedObject var bandListViewModel: BandListViewModel
    @State private var isSettingsPopoverDisplayed: Bool = false
    @State private var isDeleteAccountDialogDisplayed: Bool = false
    
    // MARK: - View
    
    var body: some View {
        VStack {
            BandListHeaderView(
                isBandListEditMode: $bandListViewModel.editMode,
                editBandModel: $bandListViewModel.editBandModel,
                isSettingsPopoverDisplayed: $isSettingsPopoverDisplayed,
                isDeleteAccountDialogDisplayed: $isDeleteAccountDialogDisplayed,
                bands: bandListViewModel.bands.filter { $0.canEdit(user: appState.user) }
            )
            List($bandListViewModel.bands) { band in
                BandListRowView(
                    editBandModel: $bandListViewModel.editBandModel,
                    isBandListEditMode: $bandListViewModel.editMode,
                    band: band
                )
            }
        }
        .sheet(isPresented: $bandListViewModel.isEditBandSheetDisplayed, onDismiss: nil) {
            BandEditView(
                bandListViewModel: bandListViewModel,
                editBandModel: bandListViewModel.editBandModel,
                isEditing: $bandListViewModel.isEditBandSheetDisplayed
            )
        }
        .alert("account_delete_confirm", isPresented: $isDeleteAccountDialogDisplayed) {
            Button("button_changed_mind", role: .cancel) {
                isDeleteAccountDialogDisplayed = false
            }
            Button("button_delete", role: .destructive) {
                bandListViewModel.deleteUser()
            }
        }
        
    }
}
