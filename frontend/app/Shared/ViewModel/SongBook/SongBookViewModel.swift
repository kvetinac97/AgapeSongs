//
//  SongBookViewModel.swift
//  ViewModel
//
//  Created by Ondřej Wrzecionko on 18.03.2022.
//

import SwiftUI

final class SongBookViewModel: ObservableObject {
    
    // MARK: - Public properties
    
    private let songBook: Binding<SongBook>
    
    @Published var selectedSongId: String? {
        didSet {
            if let selectedSongId = selectedSongId,
                let songId = selectedSongId.components(separatedBy: ",").first {
                appState.song = songBook.wrappedValue.songs.first(where: { $0.idString == songId })
                appState.selectedSongId = selectedSongId
            }
        }
    }
    
    // MARK: - Private properties
    
    private let appState: AppState
    
    // MARK: - Init
    
    init(context: HasAppState, _songBook: Binding<SongBook>) {
        appState = context.appState
        appState.songBookSearch = "" // clear on show
        songBook = _songBook
        
        #if os(macOS)
        selectedSongId = appState.song?.idString
        #endif
    }
    
}
