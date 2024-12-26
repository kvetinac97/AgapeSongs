//
//  ContentView.swift
//  View (macOS)
//
//  Created by Ondřej Wrzecionko on 03.03.2022.
//

import SwiftUI

struct ContentView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var appState: AppState
    @StateObject var songBookListViewModel = SongBookListViewModel(context: context)
    
    // MARK: - Body
    
    var body: some View {
        if appState.user == nil {
            LoginView()
        }
        else if appState.settings {
            NavigationView {
                BandListView()
                Text("band_list_choose_band")
                    .navigationTitle("settings")
            }
        }
        else {
            let songBook = Binding<SongBook>(
                get: { appState.songBook ?? SongBook.preview },
                set: { appState.songBook = $0 }
            )
            NavigationView {
                ZStack {
                    SongBookListView(songBookListViewModel: songBookListViewModel)
                        .opacity(appState.songBook != nil ? 0 : 1)
                    if appState.songBook != nil {
                        SongBookView(
                            songBookListViewModel: songBookListViewModel,
                            songBook: songBook
                        )
                    }
                }
                SongView(songBook: songBook)
            }
            .onAppear() { songBookListViewModel.loadSongBooks() }
        }
    }
}
