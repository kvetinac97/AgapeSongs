//
//  AlwaysPopoverModifier.swift
//  View (iOS)
//
//  Created by Ondřej Wrzecionko on 14.03.2022.
//

import SwiftUI
import UIKit

/// Modifier that enables popover to be always displayed, even on iPhone
/// source https://pspdfkit.com/blog/2022/presenting-popovers-on-iphone-with-swiftui/
struct AlwaysPopoverModifier<PopoverContent>: ViewModifier where PopoverContent: View {
    
    let isPresented: Binding<Bool>
    let contentBlock: () -> PopoverContent
    
    private class Store: ObservableObject {
        @Published var anchorView = UIView()
        @Published var isShown = false
    }
    @StateObject private var store = Store()
    
    func body(content: Content) -> some View {
        // Show popover
        if isPresented.wrappedValue && !store.isShown {
            presentPopover()
            store.isShown = true
        }
        // Hide popover
        if !isPresented.wrappedValue && store.isShown {
            let view = store.anchorView
            if let sourceVC = view.closestVC() {
                sourceVC.dismiss(animated: true)
            }
            store.isShown = false
        }
        
        return content
            .background(InternalAnchorView(view: store.anchorView))
    }
    
    private func presentPopover() {
        let contentVC = PopoverController(rootView: contentBlock(), isPresented: isPresented)
        contentVC.modalPresentationStyle = .popover
        
        let view = store.anchorView
        guard let popoverVC = contentVC.popoverPresentationController else { return }
        popoverVC.sourceView = view
        popoverVC.sourceRect = view.bounds
        popoverVC.delegate = contentVC
        
        guard let sourceVC = view.closestVC() else { return }
        if let presentedVC = sourceVC.presentedViewController {
            presentedVC.dismiss(animated: true) {
                sourceVC.present(contentVC, animated: true)
            }
        }
        else {
            sourceVC.present(contentVC, animated: true)
        }
    }
    
    private struct InternalAnchorView: UIViewRepresentable {
        typealias UIViewType = UIView
        let view: UIView
        
        func makeUIView(context: Self.Context) -> Self.UIViewType {
            view
        }
        
        func updateUIView(_ view: Self.UIViewType, context: Self.Context) {}
    }
}

extension View {
    /// Creates a view that is displayed as a popover even on iPhone
    public func alwaysPopover<Content>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) -> some View where Content: View {
        self.modifier(AlwaysPopoverModifier(
            isPresented: isPresented,
            contentBlock: content
        ))
    }
}

extension UIView {
    /// Helper extension to find closest ViewController
    func closestVC() -> UIViewController? {
        var responder: UIResponder? = self
        while responder != nil {
            if let vc = responder as? UIViewController {
                return vc
            }
            responder = responder?.next
        }
        return nil
    }
}
