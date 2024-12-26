//
//  SettingsButton.swift
//  View (iOS)
//
//  Created by Ondřej Wrzecionko on 14.03.2022.
//

import SwiftUI

struct SettingsButton: View {
    
    @EnvironmentObject var appState: AppState
    
    // MARK: - View
    
    var body: some View {
        NavigationLink(destination: BandListView()) {
            Image(systemName: "gearshape.fill")
        }
    }
}
