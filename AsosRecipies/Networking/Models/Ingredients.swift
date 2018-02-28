//
//  Ingredients.swift
//  AsosRecipies
//
//  Created by Daniel Tombor on 2018. 02. 28..
//  Copyright © 2018. danieltmbr. All rights reserved.
//

import Foundation

enum IngredientType: String, Codable {
    case baking     = "Baking"
    case condiments = "Condiments"
    case dairy      = "Dairy"
    case drinks     = "Drinks"
    case meat       = "Meat"
    case misc       = "Misc"
    case produce    = "Produce"
}

struct Ingredient: Codable {
    /** Name of the ingredient */
    let name: String
    /** Quantity (with unit) of the ingredient */
    let quantity: String
    /** Type of ingredient */
    let type: IngredientType
}
