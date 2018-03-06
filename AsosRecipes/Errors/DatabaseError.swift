//
//  DatabaseError.swift
//  AsosRecipes
//
//  Created by Daniel Tombor on 2018. 03. 04..
//  Copyright © 2018. danieltmbr. All rights reserved.
//

import Foundation

enum DatabaseError: Error {
    case cannotOpenDatabase
    case cannotWriteToDatabase(Error)
    case cannotFindRecipe
}

extension DatabaseError: LocalizedError {

    var errorDescription: String? {
        switch self {
        case .cannotOpenDatabase:
            return "error.db.open".localized()
        case .cannotWriteToDatabase:
            return "error.db.write".localized()
        case .cannotFindRecipe:
            return "error.db.find".localized()
        }
    }
}
