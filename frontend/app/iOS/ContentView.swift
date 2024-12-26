//
//  ContentView.swift
//  View (iOS)
//
//  Created by Ondřej Wrzecionko on 12.03.2022.
//

import SwiftUI

struct ContentView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var appState: AppState
    @StateObject var songBookListViewModel = SongBookListViewModel(context: context)
    
    // MARK: - View
    
    var body: some View {
        if appState.user == nil {
            NavigationView {
                LoginView()
                    .navigationBarTitleDisplayMode(.large)
            }
            .navigationViewStyle(.stack)
        }
        else {
            NavigationView {
                SongBookListView(songBookListViewModel: songBookListViewModel)
                    .navigationBarTitleDisplayMode(.inline)
            }
            .navigationViewStyle(.stack)
            .onAppear() { songBookListViewModel.loadSongBooks() }
        }
    }
}
