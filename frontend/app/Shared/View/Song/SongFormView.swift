//
//  SongFormView.swift
//  View
//
//  Created by Ondřej Wrzecionko on 30.03.2022.
//

import SwiftUI

struct SongFormView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var appState: AppState
    @ObservedObject var songEditViewModel: SongEditViewModel
    @ObservedObject var songBookListViewModel: SongBookListViewModel
    @Binding var songBooks: [SongBook]
    
    // MARK: - View
    
    var body: some View {
        Form {
            HStack {
                Text("song_name")
                    .font(.headline)

                TextField("", text: $songEditViewModel.name)
                    .multilineTextAlignment(_multilineFormAlignment)
            }
            
            HStack {
                Text("song_number")
                    .font(.headline)

                #if os(macOS)
                TextField("", text: $songEditViewModel.displayId)
                    .multilineTextAlignment(_multilineFormAlignment)
                #else
                TextField("", text: $songEditViewModel.displayId)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(_multilineFormAlignment)
                #endif
            }
            
            HStack {
                Text("song_songbook")
                    .font(.headline)
                
                let songBooks = songBooks.filter { songBook in songBook.canEdit(user: appState.user) }
                Picker("", selection: $songEditViewModel.songBookId) {
                    ForEach(songBooks) { songBook in
                        Text(songBook.name)
                    }
                }
                .onAppear {
                    // If there is only one song book, select it automatically
                    if songBooks.count == 1, let songBook = songBooks.first {
                        songEditViewModel.songBookId = songBook.id
                    }
                }
            }
            
            HStack {
                Text("song_key")
                    .font(.headline)
                
                Picker("", selection: $songEditViewModel.key) {
                    ForEach(SongKey.allCases, id: \.localized) { key in
                        Text(key.localized)
                            .tag(key)
                    }
                }
            }
            
            HStack {
                Text("song_bpm")
                    .font(.headline)

                #if os(macOS)
                TextField("", text: $songEditViewModel.bpm)
                    .multilineTextAlignment(_multilineFormAlignment)
                #else
                TextField("", text: $songEditViewModel.bpm)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(_multilineFormAlignment)
                #endif
            }
            
            HStack {
                Text("song_beat")
                    .font(.headline)
                
                Picker("", selection: $songEditViewModel.beat) {
                    ForEach(SongBeat.allCases, id: \.localized) { beat in
                        Text(beat.localized)
                            .tag(beat)
                    }
                }
            }
            
            HStack {
                Text("song_default_capo")
                    .font(.headline)
                
                #if os(macOS)
                TextField("", text: $songEditViewModel.capo)
                    .multilineTextAlignment(_multilineFormAlignment)
                #else
                TextField("", text: $songEditViewModel.capo)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(_multilineFormAlignment)
                #endif
            }
            
            HStack {
                Text("song_note")
                    .font(.headline)
                
                TextField("", text: $songEditViewModel.note)
                    .multilineTextAlignment(_multilineFormAlignment)
            }
            
            VStack {
                HStack {
                    Text("song_chords_text")
                        .font(.headline)
                    Spacer()
                }
                Spacer()
                TextEditor(text: $songEditViewModel.text)
                    .font(.custom(
                        "Bitstream Vera Sans Mono",
                        size: 16,
                        relativeTo: .body
                    ).monospaced())
                    .padding([.top, .bottom])
            }
        }
        .toolbar {
            #if os(macOS)
            #else
            ToolbarItemGroup(placement: _toolbarPlacementLeading) {
                Button("button_close") { appState.editSong = nil }
            }
            #endif
            
            ToolbarItemGroup(placement: _toolbarPlacementTrailing) {
                #if os(macOS)
                Button("button_close") { appState.editSong = nil }
                #endif
                
                if songEditViewModel.isValid() {
                    Button("button_submit", action: songEditViewModel.createOrEditSong)
                }
                else {
                    Button("button_submit") {}
                        .disabled(true)
                }
            }
        }
    }
}
