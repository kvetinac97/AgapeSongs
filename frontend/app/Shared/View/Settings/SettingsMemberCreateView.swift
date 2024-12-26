//
//  SettingsMemberCreateView.swift
//  View
//
//  Created by Ondřej Wrzecionko on 14.03.2022.
//

import SwiftUI

struct SettingsMemberCreateView: View {
    
    // MARK: - Properties
    
    @ObservedObject var bandViewModel: BandViewModel
    @State private var isBandMemberCreateAlertDisplayed: Bool = true
    
    // MARK: - View
    
    var body: some View {
        SheetView {
            VStack {
                // Loading state
                if bandViewModel.loading {
                    // Not done yet
                    if !bandViewModel.isBandMemberAlertDisplayed {
                        ProgressView()
                    }
                    // Done, display success dialog
                    else {
                        ProgressView()
                            .alert(
                                bandViewModel.bandMemberAlertText,
                                isPresented: $isBandMemberCreateAlertDisplayed
                            ) {
                                Button("button_ok") {
                                    bandViewModel.bandMemberAlertText = ""
                                    bandViewModel.isCreateMemberDisplayed = false
                                    bandViewModel.loading = false
                                }
                            }
                    }
                }
                else {
                    Form {
                        HStack {
                            Text("band_member_create_name")
                                .font(.headline)
                                .textContentType(_nameContentType)

                            TextField("", text: $bandViewModel.memberName)
                                .multilineTextAlignment(_multilineFormAlignment)
                        }
                        
                        HStack {
                            Text("band_member_create_email")
                                .font(.headline)
                                .textContentType(_mailContentType)

                            TextField("", text: $bandViewModel.memberEmail)
                                .multilineTextAlignment(_multilineFormAlignment)
                        }
                        
                        HStack {
                            Text("band_member_create_role")
                                .font(.headline)
                            
                            Picker("", selection: $bandViewModel.memberRole) {
                                ForEach(RoleLevel.allCases, id: \.rawValue) { role in
                                    Text(role.displayName)
                                        .tag(role)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("band_member_create")
            .foregroundColor(Color("Light"))
            .toolbar {
                #if os(macOS)
                #else
                ToolbarItemGroup(placement: _toolbarPlacementLeading) {
                    Button("button_close") { bandViewModel.isCreateMemberDisplayed = false }
                }
                #endif
                
                ToolbarItemGroup(placement: _toolbarPlacementTrailing) {
                    #if os(macOS)
                    Button("button_close") { bandViewModel.isCreateMemberDisplayed = false }
                    #endif
                    
                    if !bandViewModel.loading && bandViewModel.isValid() {
                        Button("button_submit") { bandViewModel.create() }
                    }
                    else {
                        Button("button_submit") {}
                            .disabled(true)
                    }
                }
            }
        }
        .textCase(nil)
        .font(.none)
    }
}

#if os(macOS)
private let _nameContentType: NSTextContentType = .username
private let _mailContentType: NSTextContentType = .username
#else
private let _nameContentType: UITextContentType = .name
private let _mailContentType: UITextContentType = .emailAddress
#endif
