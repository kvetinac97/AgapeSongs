//
//  ErrorView.swift
//  View
//
//  Created by Ondřej Wrzecionko on 09.03.2022.
//

import SwiftUI

struct ErrorView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var appState: AppState
    
    let error: String
    let action: (() -> Void)?
    let dismiss: (() -> Void)?
    let offline: (() -> Void)?
    
    // MARK: - View
    
    var body: some View {
        VStack {
            Text(NSLocalizedString("loading_failed", comment: "") + error)
            HStack {
                if let action = action {
                    Button("button_try_again") { action() }
                    if let offline = offline {
                        Spacer()
                        Button("button_offline") {
                            offline()
                            if let dismiss = dismiss {
                                dismiss()
                            }
                        }
                    }
                }
                if action != nil && dismiss != nil {
                    Spacer()
                }
                if let dismiss = dismiss {
                    Button("button_close") { dismiss() }
                }
            }
            .padding([.leading, .trailing])
            .padding([.top], 4)
        }
        .font(.system(size: appState.defaultFontSize))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}
