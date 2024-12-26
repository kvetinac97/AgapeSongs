//
//  SongView.swift
//  View
//
//  Created by Ondřej Wrzecionko on 10.03.2022.
//

import SwiftUI

struct SongView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var appState: AppState
    @StateObject var songViewModel = SongViewModel(context: context)
    @Binding var songBook: SongBook
    
    // MARK: - View
    
    var body: some View {
        if let song = appState.song {
            // Use the reader to find out max line characters
            SongWidthReaderView(
                songViewModel: songViewModel,
                song: song
            ) { maxLineChars in
                // Map and reduce lines into one big Text instance
                songViewModel.textWithInformation(song: song).flatMap {
                    songViewModel.divide(line: $0, with: maxLineChars)
                }.map { line in
                    let text = Text(line.text).foregroundColor(.black)
                    if let chords = songViewModel.transposeAndHide(line: line, song: song) {
                        return Text(chords).foregroundColor(.red) + Text("\n") + text
                    }
                    return text
                }
                .reduce(Text(""), { $0 + Text("\n") + $1 })
                .font(.custom("Bitstream Vera Sans Mono", size: songViewModel.textSize).monospaced())
            }
            .navigationTitle(song.displayName)
            .toolbar {
                ToolbarItem(placement: _toolbarPlacementTrailing) {
                    Button(action: { songViewModel.isSongSettingsPopoverShown = true }) {
                        Image(systemName: "pencil")
                    }
                    .alwaysPopover(isPresented: $songViewModel.isSongSettingsPopoverShown) {
                        SongSettingsView(songViewModel: songViewModel, isPresented: $songViewModel.isSongSettingsPopoverShown, song: song)
                            .environmentObject(appState)
                    }
                }
            }
            // Set SongViewModel song based on AppState navigation
            .onAppear {
                songViewModel.song = appState.song
            }
            .onChange(of: appState.song) { song in
                songViewModel.song = song
                songViewModel.changeSongClick()
            }
        }
        else {
            Text("no_song_selected")
        }
    }
    
}
