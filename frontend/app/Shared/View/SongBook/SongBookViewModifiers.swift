//
//  SongBookViewModifiers.swift
//  View
//
//  Created by Ondřej Wrzecionko on 14.03.2022.
//

import SwiftUI

extension View {
    /// Activates toolbar items for SongBookView
    func applySongBookModifiers(
        appState: AppState,
        songBook: SongBook,
        backButton: Bool = false
    ) -> some View {
        self.toolbar {
            ToolbarItemGroup(placement: _toolbarPlacementTrailing) {
                if backButton {
                    Button("button_back") { appState.songBook = nil }
                }
                
                if appState.editMode && songBook.canEdit(user: appState.user) {
                    Button(action: { appState.editSong = .create }) {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
        }
    }
}
