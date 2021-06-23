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
    
    #if os(iOS)
    // Holder of all playlists
    @EnvironmentObject var playlistHolder: PlaylistHolder
    #endif

    // Current song being displayed and its size
    let song: Song
    @State private var textSize = CGFloat(25)
    
    var body: some View {
        ZStack {
            VStack {
                ScrollView {
                    ForEach(song.lines, id: \.self) { line in
                        HStack {
                            // OpenSong format - dot = chords, space = text
                            Text(line.starts(with: ".") || line.starts(with: " ") ? String(line.suffix(from: line.index(line.startIndex, offsetBy: 1))).trim() : line.trim())
                                .foregroundColor(line.starts(with: ".") ? Color.init(red: 0, green: 0, blue: 0.86666) : Color.black)
                                .font(.custom("Bitstream Vera Sans Mono", size: textSize))
                            Spacer()
                        }
                    }
                }
                Spacer()
            }
            VStack {
                Spacer()
                #if os(iOS)
                HStack {
                    if song.listId == 0 && song.songId != 0 {
                        NavigationLink(
                            destination: SongView(song: playlistHolder.lists[0].songs[song.songId - 1]),
                            label: { Image(systemName: "arrow.left.circle.fill").resizable().frame(width: 50, height: 50).accentColor(.blue.opacity(0.5)) }
                        )
                    }
                    Spacer()
                    if song.listId == 0 && song.songId != playlistHolder.lists[0].songs.endIndex - 1 {
                        NavigationLink(
                            destination: SongView(song: playlistHolder.lists[0].songs[song.songId + 1]),
                            label: { Image(systemName: "arrow.right.circle.fill").resizable().frame(width: 50, height: 50).accentColor(.blue.opacity(0.5)) }
                        )
                    }
                }
                .navigationBarTitle(song.realId, displayMode: .inline)
                .padding([.bottom, .leading, .trailing])
                #endif
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

