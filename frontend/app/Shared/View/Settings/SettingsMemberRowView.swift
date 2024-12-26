//
//  SettingsMemberRowView.swift
//  View
//
//  Created by Ondřej Wrzecionko on 14.03.2022.
//

import SwiftUI

struct SettingsMemberRowView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var appState: AppState
    @State var isMemberDeleteDisplayed: Bool = false
    
    @ObservedObject var bandViewModel: BandViewModel
    let member: BandMember
    
    // MARK: - View
    
    var body: some View {
        HStack {
            Text(member.displayName(for: appState))
                .font(.system(size: appState.defaultFontSize))
            Spacer()
            
            // Cannot edit current user
            let isMemberCurrentUser = member.userId == appState.user?.id
            if bandViewModel.editMode && !isMemberCurrentUser {
                if let level = member.role.higherLevel() {
                    SettingsMemberRowButtonView(
                        bandViewModel: bandViewModel,
                        member: member,
                        level: level,
                        image: "arrow.up.circle.fill"
                    )
                }
                
                if let level = member.role.lowerLevel() {
                    SettingsMemberRowButtonView(
                        bandViewModel: bandViewModel,
                        member: member,
                        level: level,
                        image: "arrow.down.circle.fill"
                    )
                }
            }
            
            // Deletion is allowed when:
            // - editMode is on and edited user is not current user
            // - editMode is off and current user is not LEADER
            if (!bandViewModel.editMode && isMemberCurrentUser && member.role != .LEADER) ||
                (bandViewModel.editMode && !isMemberCurrentUser) {
                Button(action: { isMemberDeleteDisplayed = true }) {
                    Image(systemName: "xmark.circle.fill")
                        .resize(appState: appState)
                }
                .alert(
                    member.userId == appState.user?.id ? NSLocalizedString("band_member_leave_confirm", comment: "") : NSLocalizedString("band_member_delete_confirm", comment: "") + member.name + "?",
                    isPresented: $isMemberDeleteDisplayed
                ) {
                    Button("button_yes") {
                        bandViewModel.delete(member: member)
                        isMemberDeleteDisplayed = false
                    }
                    Button("button_no") { isMemberDeleteDisplayed = false }
                }
            }
        }
        .buttonStyle(BorderlessButtonStyle())
    }
}

extension BandMember {
    func displayName(for appState: AppState) -> String {
        if userId == appState.user?.id {
            return "\(name) " + NSLocalizedString("band_member_me", comment: "")
        }
        if role == .LEADER { return name }
        return "\(name) (\(role.displayName.lowercased()))"
    }
}
