//
//  ImageScaleViewModifiers.swift
//  View
//
//  Created by Ondřej Wrzecionko on 10.04.2022.
//

import SwiftUI

extension Image {
    /// Resizes image to 90 % of `AppState` text size
    func resize(appState: AppState) -> some View {
        self.resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 0.9 * appState.defaultFontSize)
    }
}
