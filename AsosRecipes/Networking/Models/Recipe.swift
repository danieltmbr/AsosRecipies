//
//  Recipe.swift
//  AsosRecipies
//
//  Created by Daniel Tombor on 2018. 02. 28..
//  Copyright © 2018. danieltmbr. All rights reserved.
//

import Foundation

struct Recipe: Codable {
    /** Name of the recipe */
    let name: String
    /** Ingredients of the recipe */
    let ingredients: [Ingredient]
    /** Steps of the recipe */
    let steps: [String]
    /** Timer for the steps in minutes */
    let timers: [Int]
    /** Cover image url */
    let imageURL: URL
    /** Optional, original recipe url */
    let originalURL: String?
}
