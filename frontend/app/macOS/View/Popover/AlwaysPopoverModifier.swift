//
//  AlwaysPopoverModifier.swift
//  View (macOS)
//
//  Created by Ondřej Wrzecionko on 14.03.2022.
//

import SwiftUI

extension View {
    /// Common method, on macOS, it displays a normal popover
    public func alwaysPopover<Content>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) -> some View where Content: View {
        self.popover(isPresented: isPresented, content: content)
    }
}
