//
//  Difficulty.swift
//  AsosRecipes
//
//  Created by Daniel Tombor on 2018. 03. 04..
//  Copyright © 2018. danieltmbr. All rights reserved.
//

import Foundation

enum Difficulty: CustomStringConvertible {
    case rookie, intermediate, advanced, any

    var title: String {
        switch self {
        case .rookie: return "difficulty.rookie".localized(comment: "Title for 'rookie difficulty' button")
        case .intermediate: return "difficulty.intermediate".localized(comment: "Title for 'intermediate difficulty' button")
        case .advanced: return "difficulty.advanced".localized(comment: "Title for 'advanced difficulty' button")
        case .any: return "difficulty.any".localized(comment: "Title for 'any difficulty' button")
        }
    }

    var description: String {
        return title
    }
}
