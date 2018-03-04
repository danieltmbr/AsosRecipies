//
//  RecipeModel.swift
//  AsosRecipes
//
//  Created by Daniel Tombor on 2018. 03. 04..
//  Copyright © 2018. danieltmbr. All rights reserved.
//

import RealmSwift

final class RecipeModel: Object {
    /** Title of the recipe */
    @objc dynamic var title: String = ""
    /** Cover image url */
    @objc dynamic var imageURL: String = ""
    /** Optional, original recipe url */
    @objc dynamic var originalURL: String = ""
    /** Difficulty */
    @objc dynamic var difficulty: Double = 0
    /** Ingredients of the recipe */
    let ingredients = List<IngredientModel>()
    /** Steps of the recipe */
    let steps = List<StepModel>()
}
