//
//  Duration.swift
//  AsosRecipes
//
//  Created by Daniel Tombor on 2018. 03. 04..
//  Copyright © 2018. danieltmbr. All rights reserved.
//

import Foundation

enum Duration: CustomStringConvertible {
    /** 0 - 10 minutes */
    case quick
    /** 10 - 20 minutes */
    case medium
    /** > 20 minutes */
    case slow
    /** from zero to infinity */
    case any

    var title: String {
        switch self {
        case .quick: return "duration.quick".localized(comment: "Title for 'quick duration' button")
        case .medium: return "duration.medium".localized(comment: "Title for 'medium duration' button")
        case .slow: return "duration.slow".localized(comment: "Title for 'slow duration' button")
        case .any: return "duration.any".localized(comment: "Title for 'any duration' button")
        }
    }

    var description: String {
        return title
    }
}
