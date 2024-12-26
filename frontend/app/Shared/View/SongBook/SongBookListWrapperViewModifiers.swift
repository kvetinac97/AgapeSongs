//
//  SongBookListModifiers.swift
//  View
//
//  Created by Ondřej Wrzecionko on 14.03.2022.
//

import SwiftUI

extension SongBookListWrapperView {
    /// Activates toolbar items for SongBookListWrapper
    func applyModifiers(
        appState: EnvironmentObject<AppState>,
        songBookListViewModel: ObservedObject<SongBookListViewModel>,
        isSongBookFilterDisplayed: Binding<Bool>
    ) -> some View {
        self.toolbar {
            #if os(macOS)
            let canDisplay = appState.wrappedValue.songBook == nil
            #else
            let canDisplay = true
            #endif
            
            ToolbarItem(placement: _toolbarPlacementLeading) {
                if canDisplay && !appState.wrappedValue.editMode {
                    SettingsButton()
                }
            }
            
            ToolbarItem(placement: _toolbarPlacementTrailing) {
                if canDisplay && appState.wrappedValue.editMode {
                    Button(action: { appState.wrappedValue.editSongBook = .create }) {
                        Image(systemName: "plus.circle.fill")
                    }
                }
                else if canDisplay {
                    Button(action: { isSongBookFilterDisplayed.wrappedValue = true }) {
                        Image(systemName: appState.wrappedValue.songBookFilter.isEmpty ? "ellipsis.circle" : "ellipsis.circle.fill")
                    }
                    .alwaysPopover(isPresented: isSongBookFilterDisplayed) {
                        SongBookListFilterView(
                            songBookListViewModel: songBookListViewModel.wrappedValue,
                            isSongBookFilterDisplayed: isSongBookFilterDisplayed
                        )
                        .environmentObject(appState.wrappedValue)
                        .frame(width: 280, height: (CGFloat(songBookListViewModel.wrappedValue.songBooks.count) * 40 + 240) * _sizePlatformCoefficient)
                    }
                }
            }
        }
        .sheet(item: appState.projectedValue.editSongBook, onDismiss: nil) { editSongBook in
            SongBookEditView(
                editSongBook: editSongBook,
                songBookListViewModel: songBookListViewModel.wrappedValue
            )
        }
        .sheet(item: appState.projectedValue.editSong, onDismiss: nil) { editSong in
            SongEditView(
                editSong: editSong,
                songBookListViewModel: songBookListViewModel.wrappedValue
            )
        }
        .applyAlertModifiers(appState: appState, songBookListViewModel: songBookListViewModel)
        .alert(
            songBookListViewModel.wrappedValue.playlistAlertText,
            isPresented: $songBookListViewModel.isPlaylistAlertDisplayed
        ) {
            // Hide dialog
            Button("button_ok") {
                songBookListViewModel.wrappedValue.playlistAlertText = ""
                songBookListViewModel.wrappedValue.isPlaylistEditLoading = false
                songBookListViewModel.wrappedValue.isPlaylistViewLoading = false
            }
        }
        // Bind AppState changes to ViewModel property (Mac only)
        .onChange(of: appState.wrappedValue.song) { song in
            #if os(macOS)
            songBookListViewModel.wrappedValue.selectedSongId = song?.idString
            #endif
        }
    }
}

extension View {
    /// Create all necessary alerts
    fileprivate func applyAlertModifiers(
        appState: EnvironmentObject<AppState>,
        songBookListViewModel: ObservedObject<SongBookListViewModel>
    ) -> some View {
        self.alert(
            NSLocalizedString("songbook_delete_confirm", comment: "") + (appState.wrappedValue.deleteSongBook?.name ?? "") + "?",
            isPresented: appState.projectedValue.isSongBookDeleteDisplayed,
            presenting: appState.wrappedValue.deleteSongBook
        ) { songBook in
            Button("button_yes") { songBookListViewModel.wrappedValue.delete(songBook: songBook) }
            Button("button_no") { appState.wrappedValue.deleteSongBook = nil }
        }
        .alert(
            songBookListViewModel.wrappedValue.deleteSongBookError.isEmpty ? NSLocalizedString("songbook_delete_success", comment: "") : NSLocalizedString("songbook_delete_error", comment: "") + songBookListViewModel.wrappedValue.deleteSongBookError,
            isPresented: songBookListViewModel.projectedValue.isDeleteSongBookDone
        ) {
            // Hide dialog
            Button("button_ok") { songBookListViewModel.wrappedValue.isDeleteSongBookDone = false }
        }
        .alert(
            NSLocalizedString("song_delete_confirm", comment: "") + (appState.wrappedValue.deleteSong?.name ?? "") + "?",
            isPresented: appState.projectedValue.isSongDeleteDisplayed,
            presenting: appState.wrappedValue.deleteSong
        ) { song in
            Button("button_yes") { songBookListViewModel.wrappedValue.delete(song: song) }
            Button("button_no") { appState.wrappedValue.deleteSong = nil }
        }
        .alert(
            songBookListViewModel.wrappedValue.deleteSongError.isEmpty ? NSLocalizedString("song_delete_success", comment: "") : NSLocalizedString("song_delete_error", comment: "") + songBookListViewModel.wrappedValue.deleteSongError,
            isPresented: songBookListViewModel.projectedValue.isDeleteSongDone
        ) {
            // Hide dialog
            Button("button_ok") { songBookListViewModel.wrappedValue.isDeleteSongDone = false }
        }
        .alert(songBookListViewModel.wrappedValue.joinBandError.isEmpty ? NSLocalizedString("band_join_success", comment: "") :
            NSLocalizedString("band_join_error", comment: "") + songBookListViewModel.wrappedValue.joinBandError,
               isPresented: songBookListViewModel.projectedValue.isJoinBandDone) {
            // Hide dialog
            Button("button_ok") { songBookListViewModel.wrappedValue.isJoinBandDone = false }
        }
    }
}
