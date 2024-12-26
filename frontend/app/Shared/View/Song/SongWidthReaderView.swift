//
//  SongWidthReaderView.swift
//  View
//
//  Created by Ondřej Wrzecionko on 22.03.2022.
//

import SwiftUI

/// Specific view used to count and read width of `Text` with given text size
struct SongWidthReaderView<Content>: View where Content: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var appState: AppState
    @ObservedObject var songViewModel: SongViewModel
    
    let song: Song
    let content: (Int) -> Content
    
    // MARK: - View
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                    // Draw content when we know max character count
                    if let maxChars = songViewModel.maxLineChars {
                        HStack {
                            content(maxChars)
                            Spacer()
                        }
                    }
                    // Helper view to calculate
                    Text("X")
                        .hidden()
                        .font(.custom(
                            "Bitstream Vera Sans Mono",
                            size: songViewModel.textSize
                        ).monospaced())
                        .readWidth($songViewModel.textWidth)
                    Spacer()
                }
            }
            .padding([.leading, .trailing, .bottom], SongViewModel.Constants.songViewPadding)
            VStack {
                // Metronome bar
                if let navBarColor = songViewModel.navBarColor {
                    navBarColor
                        .frame(height: 5)
                }
                
                Spacer()
                SongPlaylistNavigationView(song: song)
            }
        }
        .background(Color.white)
        .padding([.top], 4)
        .readWidth($songViewModel.viewWidth)
    }
}

// MARK: - Helpers

// GeometryReader workaround for reading view size
// source: https://www.fivestars.blog/articles/swiftui-share-layout-information/

struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}

extension View {
    func readWidth(_ width: Binding<Double?>) -> some View {
        self.background(GeometryReader { gr in
            Color.clear
                .preference(key: SizePreferenceKey.self, value: gr.size)
        })
        .onPreferenceChange(SizePreferenceKey.self) {
            width.wrappedValue = $0.width
        }
    }
}
