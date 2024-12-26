//
//  SettingsMemberRowHeaderView.swift
//  View
//
//  Created by Ondřej Wrzecionko on 14.03.2022.
//

import SwiftUI

struct SettingsMemberRowHeaderView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var appState: AppState
    @ObservedObject var bandViewModel: BandViewModel
    
    // MARK: - View
    
    var body: some View {
        HStack {
            Text("band_member_list")
                .font(.system(size: 0.7 * appState.defaultFontSize, weight: .bold))
            if bandViewModel.editMode {
                Spacer()
                Button(action: { bandViewModel.isCreateMemberDisplayed = true }) {
                    Image(systemName: "plus.circle.fill")
                        .resize(appState: appState)
                }
                .buttonStyle(BorderlessButtonStyle())
                .sheet(isPresented: $bandViewModel.isCreateMemberDisplayed, onDismiss: nil) {
                    SettingsMemberCreateView(bandViewModel: bandViewModel)
                }
                .alert(
                    bandViewModel.bandMemberAlertText,
                    isPresented: $bandViewModel.isBandMemberAlertDisplayed
                ) {
                    Button("button_ok") {
                        bandViewModel.loading = false
                        bandViewModel.bandMemberAlertText = ""
                    }
                }
            }
        }
    }
}
