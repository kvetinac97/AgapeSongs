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
    @State private var selection: Song? = nil
    
    #if os(iOS)
    // Offset of song view
    @State private var offset: CGSize = .zero
    #endif
    
    var body: some View {
         NavigationView {
            #if os(macOS)
            LeftMenu(selection: $selection)
            
            // Content (right part)
            if selection == nil {
                Text("No songs selected.")
                    .foregroundColor(.black)
            }
            else {
                ZStack {
                    SongView(selection: $selection, song: selection!)
                       
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
            
            #if os(iOS)
            ZStack {
                LeftMenu(selection: $selection)
                if selection != nil {
                    SongView(offset: $offset, selection: $selection, song: selection!)
                        .offset(x: offset.width, y: offset.height)
                        .animation(.interactiveSpring(), value: offset)
                }
            }
            #endif
        }
        .background(Color.white)
        .onAppear(perform: playlistHolder.loadSongs)
        .onDisappear(perform: playlistHolder.savePlaylist)
    }
    
}
