//
//  UserService.swift
//  Service
//
//  Created by Ondřej Wrzecionko on 06.06.2022.
//

import Foundation

/// Protocol for Login service
protocol UserServicing {
    /// Deletes user with `id` from application
    func delete(userId: Int) async -> Result<Void, HttpStatusError>
}

/// Helper DI protocol
protocol HasUserService {
    var userService: UserServicing { get }
}

struct UserService: UserServicing {
    
    // MARK: - Properties
    
    private let networkService: NetworkServicing
    
    // MARK: - Init
    
    init(context: HasNetworkService) {
        networkService = context.networkService
    }
    
    // MARK: - Interface method implementation
    
    func delete(userId: Int) async -> Result<Void, HttpStatusError> {
        let response = await networkService.delete(url: Constants.deleteUrl + "/" + String(userId))
        switch response {
        case .success(_):
            return .success(Void())
        case .failure(let error):
            return .failure(error)
        }
    }
    
    // MARK: - Constants
    
    private enum Constants {
        static let deleteUrl = "/user"
    }
}

// Implementation for DI
private let _userService = UserService(context: context)

extension DI: HasUserService {
    var userService: UserServicing { _userService }
}
