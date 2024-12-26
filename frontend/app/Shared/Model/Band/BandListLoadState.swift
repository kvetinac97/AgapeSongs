//
//  BandListLoadState.swift
//  Model
//
//  Created by Ondřej Wrzecionko on 05.03.2022.
//

import Foundation

enum BandListLoadState: Equatable {
    case loading
    case failure(String)
    case success
    case empty
}
