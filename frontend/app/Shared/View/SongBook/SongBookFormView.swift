//
//  SongBookFormView.swift
//  View
//
//  Created by Ondřej Wrzecionko on 28.03.2022.
//

import SwiftUI

struct SongBookFormView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var appState: AppState
    @ObservedObject var songBookEditViewModel: SongBookEditViewModel
    @ObservedObject var bandListViewModel: BandListViewModel
    @Binding var bands: [Band]
    
    // MARK: - View
    
    var body: some View {
        Form {
            HStack {
                Text("songbook_name")
                    .font(.headline)

                TextField("", text: $songBookEditViewModel.name)
                    .multilineTextAlignment(_multilineFormAlignment)
            }
            
            HStack {
                Text("songbook_band")
                    .font(.headline)
                
                let bands = bands.filter { band in band.canEdit(user: appState.user) }
                Picker("", selection: $songBookEditViewModel.bandId) {
                    ForEach(bands) { band in
                        Text(band.name)
                    }
                }
                .onAppear {
                    // If there is only one band, select it automatically
                    if bands.count == 1, let band = bands.first {
                        songBookEditViewModel.bandId = band.id
                    }
                    
                    // If there are no suitable bands, display empty text
                    if bands.isEmpty {
                        bandListViewModel.state = .empty
                    }
                }
            }
        }
        .toolbar {
            #if os(macOS)
            #else
            ToolbarItemGroup(placement: _toolbarPlacementLeading) {
                Button("button_close") { appState.editSongBook = nil }
            }
            #endif
            
            ToolbarItemGroup(placement: _toolbarPlacementTrailing) {
                #if os(macOS)
                Button("button_close") { appState.editSongBook = nil }
                #endif
                
                if songBookEditViewModel.isValid() {
                    Button("button_submit", action: songBookEditViewModel.createOrEditSongBook)
                }
                else {
                    Button("button_submit") {}
                        .disabled(true)
                }
            }
        }
    }
}
