//
//  AgapeSongsApp.swift
//  Shared
//
//  Created by Ondřej Wrzecionko on 23.06.2021.
//

import SwiftUI

@main
struct AgapeSongsApp: App {
    var playlistHolder = PlaylistHolder()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(playlistHolder)
        }
    }
}
