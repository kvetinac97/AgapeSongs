//
//  EditState.swift
//  Model
//
//  Created by Ondřej Wrzecionko on 28.03.2022.
//

import Foundation

enum EditState: Equatable {
    case idle
    case submitting
    case failure(String)
    case success
}
