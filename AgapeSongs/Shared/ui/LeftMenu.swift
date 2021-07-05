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
    
    // Binding of selection
    @Binding var selection: Song?
    
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
                            SongListItem(selection: $selection, song: song)
                        }
                    }
                }
            }
            Spacer()
        
            #if os(iOS)
            TextField("Search", text: $searched)
                .padding()
                .navigationBarTitle(selection?.realId ?? "AgapeSongs", displayMode: .inline)
            #endif
            
            #if os(macOS)
            TextField("Search", text: $searched)
                .padding()
                .background(KeyEventHandling(text: $searched, selection: $selection, lists: $playlistHolder.lists))
            #endif
        }
    }
}
