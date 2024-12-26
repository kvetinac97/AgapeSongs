//
//  BandEditView.swift
//  AgapeSongs
//
//  Created by Ondřej Wrzecionko on 01.05.2023.
//

import SwiftUI

struct BandEditView: View {
    
    // MARK: - Properties
    
    @StateObject private var bandEditViewModel: BandEditViewModel
    @State private var isBandCreateAlertDisplayed: Bool = true
    
    @Binding var isEditing: Bool
    
    // MARK: - Init
    
    init(
        bandListViewModel: BandListViewModel,
        editBandModel: EditModel<Band>?,
        isEditing: Binding<Bool>
    ) {
        self._bandEditViewModel = StateObject(wrappedValue: BandEditViewModel(
            context: context,
            bandListViewModel: bandListViewModel,
            editBandModel: editBandModel ?? .create
        ))
        self._isEditing = isEditing
    }
    
    // MARK: - View
    
    var body: some View {
        SheetView {
            VStack {
                // Loading state
                if bandEditViewModel.loading {
                    // Not done yet
                    if !bandEditViewModel.isBandAlertDisplayed {
                        ProgressView()
                    }
                    // Done, display success dialog
                    else {
                        ProgressView()
                            .alert(
                                bandEditViewModel.bandAlertText,
                                isPresented: $isBandCreateAlertDisplayed
                            ) {
                                Button("button_ok") {
                                    bandEditViewModel.bandAlertText = ""
                                    bandEditViewModel.loading = false
                                    isEditing = false
                                }
                            }
                    }
                }
                else {
                    Form {
                        Section("band_name") {
                            TextField("", text: $bandEditViewModel.bandName)
                        }
                        
                        Section(content: {
                            TextField("", text: $bandEditViewModel.bandSecret)
                        },
                        header: {
                            Text("band_secret")
                        },
                        footer: {
                            Text("band_secret_information")
                                .foregroundColor(.gray)
                        })
                    }
                    .foregroundColor(Color("Light"))
                    .toolbar {
                        #if os(macOS)
                        #else
                        ToolbarItemGroup(placement: _toolbarPlacementLeading) {
                            Button("button_close") { isEditing = false }
                        }
                        #endif
                        
                        ToolbarItemGroup(placement: _toolbarPlacementTrailing) {
                            #if os(macOS)
                            Button("button_close") { isEditing = false }
                            #endif
                            
                            if bandEditViewModel.isValid() {
                                Button("button_submit") { bandEditViewModel.submit() }
                            }
                            else {
                                Button("button_submit") {}
                                    .disabled(true)
                            }
                        }
                    }
                    .alert(
                        bandEditViewModel.bandAlertText,
                        isPresented: $bandEditViewModel.isBandAlertDisplayed
                    ) {
                        Button("button_ok") {
                            bandEditViewModel.loading = false
                            bandEditViewModel.bandAlertText = ""
                        }
                    }
                }
            }
            .navigationTitle(bandEditViewModel.editBandModel == .create ? "band_create_or_join" : "band_edit")
        }
        .textCase(nil)
        .font(.none)
        
    }
}
