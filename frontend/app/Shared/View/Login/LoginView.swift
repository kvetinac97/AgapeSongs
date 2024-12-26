//
//  LoginView.swift
//  View
//
//  Created by Ondřej Wrzecionko on 03.03.2022.
//

import AuthenticationServices
import SwiftUI

struct LoginView: View {
    
    // MARK: - Properties
    
    @StateObject var loginViewModel = LoginViewModel(context: context)
    @Environment(\.colorScheme) var colorScheme
    
    // MARK: - View
    
    var body: some View {
        VStack {
            switch loginViewModel.state {
            case .loading, .success:
                ProgressView()
            case .idle:
                SignInWithAppleButton(.signIn, onRequest: { request in request.requestedScopes = [.email, .fullName] }) { result in loginViewModel.appleAuth(result: result) }
                    .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
                    .aspectRatio(contentMode: _buttonContentMode)
                    .frame(maxWidth: .infinity)
            case .failure(let error):
                ErrorView(error: error, action: loginViewModel.retryAuth, dismiss: nil, offline: nil)
            }
        }
        .navigationTitle("login")
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#if os(macOS)
private let _buttonContentMode: ContentMode = .fill
#else
private let _buttonContentMode: ContentMode = .fit
#endif
