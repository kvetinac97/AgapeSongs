//
//  AuthService.swift
//  Service
//
//  Created by Ondřej Wrzecionko on 03.03.2022.
//

import Foundation

/// Service helping for logging in and out
protocol AuthServicing {
    /// Actually logged user (`nil` when logged out)
    var user: UserLoginDTO? { get }
    
    /// Save information about the user actually logged in to database
    func login (user: UserLoginDTO)
    /// Remove information about the logged user
    func logout ()
}

/// Helper DI protocol
protocol HasAuthService {
    var authService: AuthServicing { get }
}

struct AuthService: AuthServicing {
    
    // MARK: - Properties
    
    var user: UserLoginDTO? {
        getUser()
    }
    
    // MARK: - Public methods

    func login(user: UserLoginDTO) {
        let encoder = JSONEncoder()
        let data = try? encoder.encode(user)
        UserDefaults.standard.setValue(data, forKey: Constants.userSavePath)
    }
    
    func logout() {
        // Clear all user data and caches on logout
        UserDefaults.standard.dictionaryRepresentation().keys.forEach {
            UserDefaults.standard.removeObject(forKey: $0)
        }
    }
    
    // MARK: - Private helpers
    
    private func getUser() -> UserLoginDTO? {
        guard let data = UserDefaults.standard.data(forKey: Constants.userSavePath) else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode(UserLoginDTO.self, from: data)
    }

    // MARK: - Constants
    
    private enum Constants {
        static let userSavePath = "user_data"
    }
}

// Implementation for DI
private let _authService = AuthService()

extension DI: HasAuthService {
    var authService: AuthServicing { _authService }
}
