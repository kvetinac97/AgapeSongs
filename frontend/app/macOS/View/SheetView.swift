//
//  SheetView.swift
//  View (macOS)
//
//  Created by Ondřej Wrzecionko on 14.03.2022.
//

import SwiftUI

struct SheetView<Content>: View where Content: View {
    
    // MARK: - Properties
    
    private let frameSize: CGSize
    let content: () -> Content
    
    // MARK: - Init
    
    init(large: Bool = false, @ViewBuilder content: @escaping () -> Content) {
        self.frameSize = large ? CGSize(width: 720, height: 600) : CGSize(width: 360, height: 160)
        self.content = content
    }
    
    // MARK: - View
    
    var body: some View {
        content()
            .padding()
            .frame(
                minWidth: frameSize.width, maxWidth: .infinity,
                minHeight: frameSize.height, maxHeight: .infinity
            )
    }
}
