//
//  PopoverController.swift
//  View (iOS)
//
//  Created by Ondřej Wrzecionko on 14.03.2022.
//

import SwiftUI

/// Helper popover controller to display popover
/// source https://pspdfkit.com/blog/2022/presenting-popovers-on-iphone-with-swiftui/
class PopoverController<V>: UIHostingController<V>, UIPopoverPresentationControllerDelegate where V:View {
    var isPresented: Binding<Bool>
    
    init(rootView: V, isPresented: Binding<Bool>) {
        self.isPresented = isPresented
        super.init(rootView: rootView)
    }
    
    @MainActor @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let size = sizeThatFits(in: UIView.layoutFittingCompressedSize)
        preferredContentSize = size
    }
    
    /// Enable popover correct display on iPhone
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        self.isPresented.wrappedValue = false
    }
}
