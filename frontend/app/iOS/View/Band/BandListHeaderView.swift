//
//  BandListHeaderView.swift
//  View (iOS)
//
//  Created by Ondřej Wrzecionko on 14.03.2022.
//

import SwiftUI

struct BandListHeaderView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var appState: AppState
    @Binding var isBandListEditMode: Bool
    @Binding var editBandModel: EditModel<Band>?
    @Binding var isSettingsPopoverDisplayed: Bool
    @Binding var isDeleteAccountDialogDisplayed: Bool
    let bands: [Band]
    
    // MARK: - View
    
    var body: some View {
        VStack { }
            .toolbar {
                ToolbarItemGroup(placement: _toolbarPlacementTrailing) {
                    if isBandListEditMode {
                        Button(action: { editBandModel = .create }) {
                            Image(systemName: "plus.circle.fill")
                        }
                    }
                    else {
                        Button(action: { isSettingsPopoverDisplayed = true }) {
                            Image(systemName: "gearshape.fill")
                        }
                        .alwaysPopover(isPresented: $isSettingsPopoverDisplayed) {
                            SettingsPopoverView(isSettingsPopoverDisplayed: $isSettingsPopoverDisplayed, isDeleteAccountDialogDisplayed: $isDeleteAccountDialogDisplayed, bands: bands)
                                .environmentObject(appState)
                                .frame(width: 270, height: 460)
                        }
                    }
                }
            }
    }
}

