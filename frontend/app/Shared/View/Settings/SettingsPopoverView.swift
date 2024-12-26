//
//  SettingsPopoverView.swift
//  View
//
//  Created by Ondřej Wrzecionko on 10.04.2022.
//

import SwiftUI

struct SettingsPopoverView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var appState: AppState
    @Binding var isSettingsPopoverDisplayed: Bool
    @Binding var isDeleteAccountDialogDisplayed: Bool
    let bands: [Band]
    
    // MARK: - View
    
    var body: some View {
        #if os(macOS)
        list
        #else
        NavigationView {
            list
                .navigationTitle("settings")
                .navigationBarHidden(true)
        }
        .navigationViewStyle(.stack)
        #endif
    }
    
    var list: some View {
        List {
            Section("chord_settings") {
                Picker("", selection: $appState.chordDisplayMode) {
                    ForEach(ChordDisplayMode.allCases, id: \.localized) { setting in
                        Text(setting.localized)
                            .tag(setting)
                    }
                }
                .labelsHidden()
            }
            
            Section("default_band") {
                Picker("", selection: $appState.defaultBandId) {
                    ForEach(bands) { band in
                        Text(band.name)
                            .tag(band.id as Int?)
                    }
                    Text("no_band_selected")
                        .tag(nil as Int?)
                }
                .labelsHidden()
            }
            
            Section("size_settings") {
                Slider(value: $appState.defaultFontSize, in: 10...50)
            }
            
            #if os(macOS)
            Section("floating_mode") {
                // Reload window on band floating state
                Toggle("", isOn: $appState.isWindowFloating)
                    .onChange(of: appState.isWindowFloating) { _ in
                        appState.settings = false
                    }
            }
            #endif
            
            Section("account_settings") {
                Button("logout") {
                    isSettingsPopoverDisplayed = false
                    appState.logout()
                }
                Button("account_delete", role: .destructive) {
                    isSettingsPopoverDisplayed = false
                    isDeleteAccountDialogDisplayed = true
                }
            }
        }
    }
}
