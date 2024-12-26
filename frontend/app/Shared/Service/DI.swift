//
//  DI.swift
//  Service
//
//  Created by Ondřej Wrzecionko on 05.03.2022.
//

import Foundation

/// Dependency injection container
final class DI {
    
}

/// Model that needs no dependencies
protocol HasNothing {}

extension DI: HasNothing {
    
}

let context = DI()
