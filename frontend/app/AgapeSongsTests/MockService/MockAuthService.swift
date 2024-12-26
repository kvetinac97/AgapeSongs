//
//  MockAuthService.swift
//  AgapeSongsTests
//
//  Created by Ondřej Wrzecionko on 05.03.2022.
//

import Foundation

@testable import AgapeSongs

class MockAuthService: AuthServicing {
    init() {}
    
    var user: UserLoginDTO? = nil
    private(set) var loginCalled = false
    
    func login(user: UserLoginDTO) {
        loginCalled = true
        self.user = user
    }
    
    func logout() {
        self.user = nil
    }
}
