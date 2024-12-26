//
//  LoginService.swift
//  Service
//
//  Created by Ondřej Wrzecionko on 03.03.2022.
//

import Foundation

/// Protocol for Login service
protocol LoginServicing {
    /// Logs user in based on Sign with Apple credentials
    func login(credentials: AppleLoginDTO) async -> Result<UserLoginDTO, HttpStatusError>
}

/// Helper DI protocol
protocol HasLoginService {
    var loginService: LoginServicing { get }
}

struct LoginService: LoginServicing {
    
    // MARK: - Properties
    
    private let networkService: NetworkServicing
    
    // MARK: - Init
    
    init(context: HasNetworkService) {
        networkService = context.networkService
    }
    
    // MARK: - Interface method implementation
    
    func login(credentials: AppleLoginDTO) async -> Result<UserLoginDTO, HttpStatusError> {
        let response = await networkService.post(url: Constants.loginUrl, body: credentials)
        switch response {
        case .success(let data):
            guard let user = try? JSONDecoder().decode(UserLoginDTO.self, from: data) else {
                return .failure(.badtext(text: "user_response_parse_error"))
            }
            return .success(user)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    // MARK: - Constants
    
    private enum Constants {
        static let loginUrl = "/user/login"
    }
}

// Implementation for DI
private let _loginService = LoginService(context: context)

extension DI: HasLoginService {
    var loginService: LoginServicing { _loginService }
}
