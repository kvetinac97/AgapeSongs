//
//  SettingsButton.swift
//  View (macOS)
//
//  Created by Ondřej Wrzecionko on 14.03.2022.
//

import SwiftUI

struct SettingsButton: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var appState: AppState
    
    // MARK: - View
    
    var body: some View {
        Button(action: { appState.settings = true }) {
            Image(systemName: "gearshape.fill")
        }
    }
}
