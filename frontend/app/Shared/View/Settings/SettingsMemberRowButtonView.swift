//
//  SettingsMemberRowButtonView.swift
//  View
//
//  Created by Ondřej Wrzecionko on 14.03.2022.
//

import SwiftUI

struct SettingsMemberRowButtonView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var appState: AppState
    @ObservedObject var bandViewModel: BandViewModel
    @State var isMemberChangeRoleDisplayed: Bool = false
    
    let member: BandMember
    let level: RoleLevel
    let image: String
    
    // MARK: - View
    
    var body: some View {
        Button(action: {
            isMemberChangeRoleDisplayed = true
        }) {
            Image(systemName: image)
                .resize(appState: appState)
        }
        .alert(
            NSLocalizedString("band_member_change_role_confirm", comment: "") + member.name +
            NSLocalizedString("band_member_change_role_to", comment: "") + level.displayName + "?",
            isPresented: $isMemberChangeRoleDisplayed
        ) {
            Button("button_yes") {
                bandViewModel.change(member: member, role: level)
                isMemberChangeRoleDisplayed = false
            }
            Button("button_no") { isMemberChangeRoleDisplayed = false }
        }
    }
}
