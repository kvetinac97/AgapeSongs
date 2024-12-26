//
//  AgapeSongsApp.swift
//  Shared
//
//  Created by Ondřej Wrzecionko on 03.03.2022.
//

import SwiftUI

@main
struct AgapeSongsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(_appState)
        }
    }
}

private let _appState = AppState(context: context)

extension DI: HasAppState {
    var appState: AppState { _appState }
}

// Define colors
#if os(macOS)
let _lightColor = Color.white
#else
let _lightColor = Color("Light")
#endif

// Toolbar placement works differently on macOS / iOS
#if os(macOS)
let _toolbarPlacementLeading : ToolbarItemPlacement = .navigation
let _toolbarPlacementTrailing: ToolbarItemPlacement = .automatic
#else
let _toolbarPlacementLeading : ToolbarItemPlacement = .navigationBarLeading
let _toolbarPlacementTrailing: ToolbarItemPlacement = .navigationBarTrailing
#endif

// SwiftUI forms have different behaviour
#if os(macOS)
let _multilineFormAlignment: TextAlignment = .leading
#else
let _multilineFormAlignment: TextAlignment = .trailing
#endif

// Different button style on devices
#if os(macOS)
let _buttonStyle = BorderlessButtonStyle()
#else
let _buttonStyle = DefaultButtonStyle()
#endif

// Different size platform coefficient
#if os(macOS)
let _sizePlatformCoefficient: CGFloat = 0.7
#else
let _sizePlatformCoefficient: CGFloat = 1
#endif
