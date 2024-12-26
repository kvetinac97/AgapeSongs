//
//  SettingsView.swift
//  View
//
//  Created by Ondřej Wrzecionko on 14.03.2022.
//

import SwiftUI

struct SettingsView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var appState: AppState
    @StateObject private var bandViewModel: BandViewModel
    @Binding private var band: Band
    
    // MARK: - Init
    
    init(band: Binding<Band>) {
        _bandViewModel = StateObject(
            wrappedValue: BandViewModel(band: band, context: context)
        )
        _band = band
    }
    
    // MARK: - View
    
    var body: some View {
        ZStack {
            List {
                // Leaders
                Section(content: {
                    ForEach(band.members.filter {
                        $0.role == .LEADER
                    }.sorted {
                        $0.name.localizedCompare($1.name) == .orderedAscending
                    }) { leader in
                        SettingsMemberRowView(bandViewModel: bandViewModel, member: leader)
                    }
                }, header: {
                    Text("band_leader_list")
                        .font(.system(size: appState.defaultFontSize * 0.7, weight: .bold))
                })
                // Members
                Section(
                    content: {
                        ForEach(band.members.filter {
                            $0.role != .LEADER
                        }.sorted {
                            $0.name.localizedCompare($1.name) == .orderedAscending
                        }) { member in
                            SettingsMemberRowView(bandViewModel: bandViewModel, member: member)
                        }
                    },
                    header: { SettingsMemberRowHeaderView(bandViewModel: bandViewModel) }
                )
                // Hide band
                Section(
                    content: {
                        VStack(alignment: .leading) {
                            // Hide band toggle
                            Toggle("band_hidden", isOn: $bandViewModel.isBandHidden)
                                .padding(.bottom, 8)

                            // QR Code
                            if let qrImage = bandViewModel.bandJoinQRImage {
                                Text("band_qr_image")
                                    .font(.system(size: appState.defaultFontSize * 0.7, weight: .bold))
                                
                                #if os(macOS)
                                let image = Image(nsImage: qrImage)
                                #else
                                let image = Image(uiImage: qrImage)
                                #endif
                                
                                image
                                    .interpolation(.none)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 200, height: 200)
                            }
                        }
                    }, header: {
                        Text("band_settings")
                            .font(.system(size: appState.defaultFontSize * 0.7, weight: .bold))
                    }
                )
            }
            .opacity(bandViewModel.loading ? 0 : 1)
            
            if bandViewModel.loading {
                ProgressView()
            }
        }
        .navigationTitle(band.name)
        .toolbar {
            ToolbarItem(placement: _toolbarPlacementTrailing) {
                // Edit mode is available only for leaders
                if band.members.contains(where: {
                    $0.userId == appState.user?.id && $0.role == .LEADER
                }) && !bandViewModel.loading {
                    Button(action: { bandViewModel.editMode.toggle() }) {
                        Image(systemName: bandViewModel.editMode ? "xmark" : "pencil")
                    }
                }
            }
        }
    }
}
