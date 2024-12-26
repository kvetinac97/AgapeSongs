//
//  LoginViewModel.swift
//  ViewModel
//
//  Created by Ondřej Wrzecionko on 03.03.2022.
//

import AuthenticationServices
import SwiftUI

final class LoginViewModel: ObservableObject {
    
    // MARK: - Public properties
    
    @Published private(set) var state: LoginState = .idle
    
    // MARK: - Private properties
    
    private var appState: AppState
    private var loginService: LoginServicing
    
    // MARK: - Init
    
    init (context: HasAppState & HasLoginService) {
        appState = context.appState
        loginService = context.loginService
    }
    
    // MARK: - Public methods
    
    func appleAuth(result: Result<ASAuthorization, Error>) {
        state = .loading
        
        guard case .success(let result) = result,
              let credential = result.credential as? ASAuthorizationAppleIDCredential,
              let code = credential.authorizationCode,
              let authorizationCode = String(data: code, encoding: .utf8) else {
                  state = .failure(NSLocalizedString("apple_auth_error", comment: ""))
                  return
              }
        let name = credential.fullName?.formatted()

        Task {
            let appleLogin = AppleLoginDTO(code: authorizationCode, name: name)
            await appleAuth(result: appleLogin)
        }
    }
    
    func appleAuth(result: AppleLoginDTO) async {
        let result = await loginService.login(credentials: result)
        await loginCompleted(loginResult: result)
    }
    
    func retryAuth () {
        state = .idle
    }
    
    @MainActor
    private func loginCompleted(loginResult: Result<UserLoginDTO, HttpStatusError>) async {
        switch loginResult {
        case .success(let user):
            withAnimation {
                appState.login(user: user.domain)
                state = .success
            }
        case .failure(let error):
            print(error)
            state = .failure(error.errorDescription)
        }
    }
    
}
