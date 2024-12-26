//
//  EditModel.swift
//  Model
//
//  Created by Ondřej Wrzecionko on 28.03.2022.
//

import Foundation

/// Custom protocol enabling creating and editing of entities
enum EditModel<T: Equatable & IsEditModel> : Equatable, Identifiable {
    case create
    case edit(T)
    
    var id: String? {
        switch self {
        case .create:
            return nil
        case .edit(let item):
            return item.editModelId
        }
    }
}

protocol IsEditModel {
    var editModelId: String { get }
}

extension Song: IsEditModel {
    var editModelId: String {
        idString
    }
}

extension SongBook: IsEditModel {
    var editModelId: String {
        String(id)
    }
}

extension Band: IsEditModel {
    var editModelId: String {
        String(id)
    }
}
