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
    
    // Actual displayed song and editMode
    @State private var selection: Song? = nil
    @State private var editMode: Bool = false
    
    #if os(iOS)
    // Offset of song view
    @State private var offset: CGSize = .zero
    #endif
    
    var body: some View {

        // Navigation style
        #if os(macOS)
        let style = DefaultNavigationViewStyle()
        #else
        let style = StackNavigationViewStyle()
        #endif

        NavigationView {
            #if os(macOS)
            LeftMenu(selection: $selection, editMode: $editMode)
            
            // Content (right part)
            if selection == nil {
                Text("No songs selected.")
                    .foregroundColor(.black)
            }
            else {
                ZStack {
                    SongView(selection: $selection, editMode: $editMode, song: selection!)
                       
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
                LeftMenu(selection: $selection, editMode: $editMode)
                if selection != nil {
                    SongView(offset: $offset, selection: $selection, editMode: $editMode, song: selection!)
                        .offset(x: offset.width, y: offset.height)
                        .animation(.interactiveSpring(), value: offset)
                }
            }
            #endif
        }
        .background(Color.white)
        .navigationViewStyle(style)
        .onAppear(perform: playlistHolder.loadSongs)
        .onDisappear(perform: playlistHolder.savePlaylist)
    }
    
}
