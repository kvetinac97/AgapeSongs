//
//  LoginState.swift
//  Model
//
//  Created by Ondřej Wrzecionko on 05.03.2022.
//

import Foundation

enum LoginState {
    case idle
    case loading
    case failure(String)
    case success
}
