//
//  SongSettingsView.swift
//  View
//
//  Created by Ondřej Wrzecionko on 03.04.2022.
//

import SwiftUI

struct SongSettingsView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var appState: AppState
    @ObservedObject var songViewModel: SongViewModel
    @Binding var isPresented: Bool
    let song: Song
    
    // MARK: - View
    
    var body: some View {
        let canEdit = song.canEdit(user: appState.user)
        VStack {
            List {
                Section("song_settings_song") {
                    Stepper(
                        NSLocalizedString("song_settings_capo", comment: "") + String(songViewModel.capo),
                        value: $songViewModel.capo,
                        in: -(SongKey.songKeyCount - 1) ... (SongKey.songKeyCount - 1),
                        step: 1
                    )
                    if canEdit {
                        Button("song_settings_edit") {
                            isPresented = false
                            appState.editSong = .edit(song)
                        }
                    }
                    
                    if song.bpm != 999 {
                        Button(songViewModel.songClickActive ? "song_metronome_off" : "song_metronome_on") {
                            if songViewModel.songClickActive {
                                songViewModel.stopClick()
                            }
                            else {
                                songViewModel.startClick()
                            }
                        }
                    }
                }
                Section("song_settings_font_size") {
                    Slider(
                        value: Binding<CGFloat>(
                            get: { CGFloat(songViewModel.textSize) },
                            // Custom implementation of step = 0.5, as native SwiftUI slider UI is buggy
                            set: {
                                songViewModel.textSize = Double(round($0 * 2) / 2)
                            }
                        ),
                        in: 10...50
                    )
                }
            }
        }
        .frame(width: 320, height: (240 + (canEdit ? 35 : 0) + (song.bpm != 999 ? 35 : 0)) * _sizePlatformCoefficient)
    }
}
