//
//  LoginViewModelTests.swift
//  AgapeSongsTests
//
//  Created by Ondřej Wrzecionko on 05.03.2022.
//

import Foundation
import XCTest

@testable import AgapeSongs
import AuthenticationServices

final class LoginViewModelTests: AgapeSongsTestCase {
    
    private struct DI: HasAppState & HasLoginService {
        let appState: AppState
        let loginService: LoginServicing
    }
    
    private var loginService: MockLoginService!
    private var viewModel: LoginViewModel!
    
    override func setUp() {
        super.setUp()
        loginService = .init()
        setUpViewModel()
    }
    
    override func tearDown() {
        loginService = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testLoginSuccess() async {
        let mockUser = UserLoginDTO(id: 1, loginSecret: "mockloginsecret", email: "test@mockk.cz", name: "Mock")
        loginService.loginResponse = .success(mockUser)
        
        await viewModel.appleAuth(result: AppleLoginDTO(code: "mockcode123", name: nil))
        
        XCTAssertTrue(authService.loginCalled)
        XCTAssertEqual(authService.user, mockUser)
        XCTAssertEqual(appState.user, mockUser.domain)
    }
    
    func testLoginFailure() async {
        loginService.loginResponse = .failure(.badtext(text: "Mock error"))
        
        await viewModel.appleAuth(result: AppleLoginDTO(code: "mockcode123", name: nil))
        
        XCTAssertFalse(authService.loginCalled)
        XCTAssertEqual(authService.user, nil) // no login happened
        XCTAssertEqual(appState.user, nil)
    }
    
    // MARK: - Private helpers
    
    private func setUpViewModel() {
        viewModel = LoginViewModel(
            context: DI(
                appState: appState,
                loginService: loginService
            )
        )
    }
}
