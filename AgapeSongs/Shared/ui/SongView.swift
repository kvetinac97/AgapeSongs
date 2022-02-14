//
//  SongView.swift
//  AgapeSongs
//
//  Created by Ondřej Wrzecionko on 16.06.2021.
//

import SwiftUI

/*
 * Structure representing one song view
 */
struct SongView: View {
    
    // Holder of all playlists
    @EnvironmentObject var playlistHolder: PlaylistHolder
    
    #if os(iOS)
    // Offset of current SongView
    @Binding var offset: CGSize
    #endif
    
    // Current selected song
    @Binding var selection: Song?
    @Binding var editMode: Bool

    // Current song being displayed and its size
    let song: Song
    
    @State private var textSize = CGFloat(25)
    @State private var songText = ""
    
    var body: some View {
        ZStack {
            #if os(iOS)
            let gesture = DragGesture()
                .onChanged {
                    if $0.translation.width > 0 {
                        self.offset = .init(width: $0.translation.width, height: self.offset.height)
                    }
                }
                .onEnded {
                    if $0.translation.width > 100 {
                        selection = nil // swipe left
                    }
                    self.offset = .zero
            }
            #else
            let gesture = DragGesture()
            #endif

            VStack {
                if editMode {
                    TextEditor(text: $songText)
                        .lineSpacing(2)
                        .font(.custom("Bitstream Vera Sans Mono", size: textSize))
                }
                else {
                    ScrollView {
                        ForEach(song.displayLines, id: \.self) { line in
                            HStack {
                                // OpenSong format - dot = chords, space = text
                                Text(line.text.starts(with: ".") || line.text.starts(with: " ") ? String(line.text.suffix(from: line.text.index(line.text.startIndex, offsetBy: 1))).trim() : line.text.trim())
                                    .foregroundColor(line.text.starts(with: ".") ? Color.red : Color.black)
                                    .font(.custom("Bitstream Vera Sans Mono", size: textSize))
                                Spacer()
                            }
                        }
                    }
                }
                Spacer()
            }
            .gesture(gesture)
            
            VStack {
                Spacer()
                
                HStack {
                    #if os(iOS)
                    if !editMode && song.listId == 0 && song.songId(playlistHolder) != 0 {
                        Image(systemName: "arrow.left.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.blue.opacity(0.5))
                            .onTapGesture {
                                selection = playlistHolder.lists[0].songs[song.songId(playlistHolder) - 1]
                            }
                    }
                    #endif
                    Spacer()
                    
                    if song.listId != 0 {
                        #if os(macOS)
                        let size : CGFloat = 30
                        #else
                        let size : CGFloat = 50
                        #endif
                        
                        Image(systemName: "pencil.circle.fill")
                            .resizable()
                            .foregroundColor(.black)
                            .onTapGesture {
                                if editMode {
                                    playlistHolder.editSong(song: song, songText: songText, newSelection: &selection)
                                }
                                else {
                                    songText = song.lines.joined(separator: "\n")
                                }
                                editMode.toggle()
                            }
                            .frame(width: size, height: size)
                            .padding([.bottom], 10)
                    }
                    
                    #if os(iOS)
                    if !editMode && song.listId == 0 && song.songId(playlistHolder) != playlistHolder.lists[0].songs.endIndex - 1 {
                        Image(systemName: "arrow.right.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.blue.opacity(0.5))
                            .onTapGesture {
                                selection = playlistHolder.lists[0].songs[song.songId(playlistHolder) + 1]
                            }
                    }
                    #endif
                }
                .padding([.bottom, .leading, .trailing])
                
                Slider(value: Binding<CGFloat>(get: {textSize}, set: {
                    textSize = $0
                    UserDefaults.standard.setValue(Double(textSize), forKey: "SONG_SIZE_\(song.realId)")
                }), in: 10...50)
            }
            .frame(alignment: .bottom)
        }
        .padding()
        // When switching songs
        .onChange(of: song, perform: { value in
            reloadSize(song: value)
        })
        // On first song load
        .onAppear {
            reloadSize(song: song)
        }
        .background(Color.white)
    }
    
    // Help function for reloading size from file
    private func reloadSize (song: Song) {
        let value = UserDefaults.standard.double(forKey: "SONG_SIZE_\(song.realId)")
        textSize = CGFloat(value == 0 ? 25 : value)
    }
    
}

extension String {
    func trim () -> String {
        return trimmingCharacters(in: .newlines)
            .replacingOccurrences(of: "[V1]", with: " ")
            .replacingOccurrences(of: "[V2]", with: " ")
            .replacingOccurrences(of: "[V3]", with: " ")
            .replacingOccurrences(of: "[V4]", with: " ")
            .replacingOccurrences(of: "[C]", with: " ")
            .replacingOccurrences(of: "[C1]", with: " ")
            .replacingOccurrences(of: "[C2]", with: " ")
            .replacingOccurrences(of: "[B]", with: " ")
            .replacingOccurrences(of: "[P]", with: " ")
    }
}

