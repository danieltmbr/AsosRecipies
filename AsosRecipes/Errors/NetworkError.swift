//
//  NetworkError.swift
//  AsosRecipes
//
//  Created by Daniel Tombor on 2018. 03. 05..
//  Copyright © 2018. danieltmbr. All rights reserved.
//

import Foundation

enum NetworkError: Error {
    case cannotLoadRecipes(Error)
}

extension NetworkError: LocalizedError {

    var errorDescription: String? {
        switch self {
        case .cannotLoadRecipes:
            return "error.network.recipes".localized()
        }
    }
}
