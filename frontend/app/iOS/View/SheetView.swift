//
//  SheetView.swift
//  View (iOS)
//
//  Created by Ondřej Wrzecionko on 14.03.2022.
//

import SwiftUI

struct SheetView<Content>: View where Content: View {
    
    // MARK: - Properties
    
    private let content: () -> Content
    
    // MARK: - Init
    
    init(large: Bool = false, @ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    // MARK: - View
    
    var body: some View {
        NavigationView {
            content()
                .navigationViewStyle(.stack)
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
