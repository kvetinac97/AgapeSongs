//
//  LeftMenu.swift
//  AgapeSongs
//
//  Created by Ondřej Wrzecionko on 05.07.2021.
//

import SwiftUI

struct LeftMenu: View {
    
    // Holder of all playlists
    @EnvironmentObject var playlistHolder: PlaylistHolder
    
    // Binding of selection and edit/focus
    @Binding var selection: Song?
    @Binding var editMode: Bool
    
    // Actual searched text
    @State private var searched: String = ""
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(playlistHolder.lists, id: \.id) { list in
                        // Top bar
                        HStack {
                            Text(list.id)
                                .font(Font.subheadline.weight(.bold))
                            Spacer()
                        }
                        .padding(5)
                        Divider()
                        
                        // Displaying each song item
                        ForEach(list.songs.filter({
                            searched.isEmpty ? true : $0.id.lowercased().contains(searched.lowercased())
                        }), id: \.id) { song in
                            SongListItem(selection: $selection, editMode: $editMode, song: song)
                        }
                    }
                }
            }
            Spacer()
        
            HStack {
                #if os(iOS)
                TextField("Hledat", text: $searched)
                    .padding()
                    .navigationBarTitle(selection?.realId ?? "AgapeSongs", displayMode: .inline)
                #endif
                
                #if os(macOS)
                TextField("Hledat", text: $searched)
                    .padding()
                    .background(KeyEventHandling(text: $searched, selection: $selection, editMode: $editMode, lists: $playlistHolder.lists))
                #endif
                
                Spacer()
                
                Image(systemName: "plus.circle.fill")
                    .resizable()
                    .foregroundColor(.black)
                    .frame(width: 20, height: 20)
                    .padding()
                    .onTapGesture {
                        if !searched.isEmpty {
                            playlistHolder.createSong(songName: searched)
                            searched = ""
                        }
                    }
            }
        }
    }
}
