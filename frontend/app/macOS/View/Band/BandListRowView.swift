//
//  BandListRowView.swift
//  View (macOS)
//
//  Created by Ondřej Wrzecionko on 09.03.2022.
//

import SwiftUI

struct BandListRowView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var appState: AppState
    @State private var isActive: Bool = false
    
    @Binding var editBandModel: EditModel<Band>?
    @Binding var isBandListEditMode: Bool
    @Binding var band: Band
    
    // MARK: - View
    
    var body: some View {
        let canEdit = isBandListEditMode && band.canEdit(user: appState.user)
        let bandListView = HStack {
            Text(band.name)
                .font(.system(size: appState.defaultFontSize))
            Spacer()
            if canEdit {
                Button(action: { editBandModel = .edit(band) }) {
                    Image(systemName: "pencil.circle.fill")
                }
                .buttonStyle(BorderlessButtonStyle())
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if canEdit {
                editBandModel = .edit(band)
                return
            }
            appState.band = band
            isActive = true
        }
        
        if isBandListEditMode {
            bandListView
        }
        else {
            NavigationLink(destination: SettingsView(band: $band), isActive: $isActive) {
                bandListView
            }
        }
    }
}
