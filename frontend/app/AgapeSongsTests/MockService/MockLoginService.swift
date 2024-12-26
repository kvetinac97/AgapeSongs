//
//  MockLoginService.swift
//  AgapeSongsTests
//
//  Created by Ondřej Wrzecionko on 05.03.2022.
//

import Foundation

@testable import AgapeSongs

class MockLoginService: LoginServicing {
    init() {}
    
    var loginResponse: Result<UserLoginDTO, HttpStatusError>?
    
    func login(credentials: AppleLoginDTO) async -> Result<UserLoginDTO, HttpStatusError> {
        loginResponse ?? .failure(.badtext(text: "Did not provide implementation"))
    }
}
