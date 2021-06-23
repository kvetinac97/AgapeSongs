//
//  ContentView.swift
//  AgapeSongsIOS
//
//  Created by Ondřej Wrzecionko on 08.06.2021.
//

import SwiftUI

struct ContentView: View {

    // All the playlists loaded from file
    @EnvironmentObject var playlistHolder: PlaylistHolder
    
    // Actual displayed song (just on Mac)
    #if os(macOS)
        @State private var selection: Song? = nil
    #endif
    
    // Actual searched text
    @State private var searched: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                // Menu (left part)
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
                                #if os(iOS)
                                SongListItem(song: song)
                                NavigationLink(destination: EmptyView()) { EmptyView() }
                                #endif
                                
                                #if os(macOS)
                                SongListItem(selection: $selection, song: song)
                                #endif
                            }
                        }
                    }
                }
                Spacer()
                #if os(iOS)
                TextField("Search", text: $searched)
                    .padding()
                    .navigationBarTitle("AgapeSongs", displayMode: .inline)
                #endif
                
                #if os(macOS)
                TextField("Search", text: $searched)
                    .padding()
                    .background(KeyEventHandling(text: $searched, selection: $selection, lists: $playlistHolder.lists))
                #endif
            }
            
            #if os(macOS)
            // Content (right part)
            if selection == nil {
                Text("No songs selected.")
                    .foregroundColor(.black)
            }
            else {
                ZStack {
                    SongView(song: selection!)
                    HStack {
                        Spacer()
                        VStack {
                            Spacer()
                            Image(systemName: "arrow.clockwise.circle.fill")
                                .resizable()
                                .foregroundColor(.black)
                                .onTapGesture(perform: playlistHolder.loadSongs)
                                .frame(width: 30, height: 30)
                                .padding(30)
                                .padding([.bottom], 10)
                        }
                    }
                }
            }
            #endif
        }
        .background(Color.white)
        .onAppear(perform: playlistHolder.loadSongs)
        .onDisappear(perform: playlistHolder.savePlaylist)
    }
    
}
