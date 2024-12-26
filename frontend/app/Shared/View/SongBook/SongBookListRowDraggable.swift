//
//  SongBookListRowDraggable.swift
//  View
//
//  Created by Ondřej Wrzecionko on 20.03.2022.
//

import SwiftUI

extension View {
    /// Makes given song draggable
    @ViewBuilder func makeDraggable(draggedSong: Binding<Song?>, song: Song) -> some View {
        if !song.inPlaylist {
            self
        }
        else {
            self.onDrag {
                draggedSong.wrappedValue = song
                return NSItemProvider(object: song.name as NSString)
            }
        }
    }
}
