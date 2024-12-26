//
//  SongBookListLoadState.swift
//  Model
//
//  Created by Ondřej Wrzecionko on 10.03.2022.
//

import Foundation

enum SongBookListLoadState: Equatable {
    case loading
    case failure(String)
    case success
}
