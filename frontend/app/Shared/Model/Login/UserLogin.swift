//
//  UserLogin.swift
//  Model
//
//  Created by Ondřej Wrzecionko on 03.03.2022.
//

import Foundation

struct UserLogin: Equatable {
    let id: Int
    let loginSecret: String
    let email: String
    let name: String
}

extension UserLogin {
    var dto: UserLoginDTO {
        .init(
            id: id,
            loginSecret: loginSecret,
            email: email,
            name: name
        )
    }
}

extension UserLoginDTO {
    var domain: UserLogin {
        .init(
            id: id,
            loginSecret: loginSecret,
            email: email,
            name: name
        )
    }
}
