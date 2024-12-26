//
//  EditModeStackView.swift
//  View
//
//  Created by Ondřej Wrzecionko on 14.03.2022.
//

import SwiftUI

struct EditModeStackView<Content>: View where Content: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var appState: AppState
    private let editMode: Binding<Bool>?
    private let content: () -> Content
    
    // MARK: - Init
    
    init(editMode: Binding<Bool>? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.editMode = editMode
        self.content = content
    }
    
    // MARK: - View
    
    var body: some View {
        ZStack {
            content()
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    ZStack {
                        let editMode = editMode ?? $appState.editMode
                        let size = 12 + appState.defaultFontSize * 1.5
                        Circle()
                            .foregroundColor(Color("Dark"))
                            .frame(width: size, height: size)
                        Image(systemName: editMode.wrappedValue ? "pencil.circle.fill" : "pencil.circle")
                            .resizable()
                            .frame(width: size, height: size)
                            .padding(30)
                            .foregroundColor(editMode.wrappedValue ? .blue : .accentColor)
                            .onTapGesture {
                                editMode.wrappedValue.toggle()
                            }
                    }
                }
                .padding([.bottom], _editModePadding)
            }
        }
    }
}

// Different padding on different platforms
#if os(macOS)
private let _editModePadding: CGFloat = 30
#else
private let _editModePadding: CGFloat = 0
#endif
