//
//  StringExtensions.swift
//  AsosRecipes
//
//  Created by Daniel Tombor on 2018. 03. 03..
//  Copyright © 2018. danieltmbr. All rights reserved.
//

import Foundation

extension String {

    func localized(comment: String = "") -> String {
        return NSLocalizedString(self, comment: comment)
    }

    func localized(with variable: CVarArg, comment: String = "") -> String {
        return String(format: localized(comment: comment), variable)
    }
}
