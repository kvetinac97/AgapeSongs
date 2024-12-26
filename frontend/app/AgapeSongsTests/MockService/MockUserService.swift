//
//  MockUserService.swift
//  AgapeSongsTests
//
//  Created by Ondřej Wrzecionko on 06.06.2023.
//

import Foundation

@testable import AgapeSongs

class MockUserService: UserServicing {
    init() {}
    
    var deleteResponse: Result<Void, HttpStatusError>?
    
    func delete(userId: Int) async -> Result<Void, HttpStatusError> {
        deleteResponse ?? .failure(.badtext(text: "Did not provide implementation"))
    }
}
