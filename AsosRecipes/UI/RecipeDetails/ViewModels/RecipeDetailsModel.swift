//
//  RecipeDetailsModel.swift
//  AsosRecipes
//
//  Created by Daniel Tombor on 2018. 03. 05..
//  Copyright © 2018. danieltmbr. All rights reserved.
//

import Foundation

// MARK: -

struct RecipeDetailsModel: RecipeDetailsViewModel {

    /** Local identifier */
    let id: String
    /** Title of the recipe */
    let title: String
    /** String of a cover image's url */
    let coverImageUrl: URL?
    /** Collection of ingredients */
    let ingredients: [IngredientCellViewModel]
    /** Collection of steps */
    let steps: [StepCellViewModel]

    // MARK: - Initialisation

    init(model: RecipeModel) {
        id = model.id
        title = model.title
        coverImageUrl = URL(string: model.imageURL)
        ingredients = model.ingredients.map { IngredientCellModel(model: $0) }
        steps = model.steps.map { StepCellModel(model: $0) }
    }
}

// MARK: -

private struct IngredientCellModel: IngredientCellViewModel {

    let name: String

    let quantity: String

    // MARK: - Initialisation

    init(model: IngredientModel) {
        name = model.name
        quantity = model.quantity
    }
}

// MARK: -

private struct StepCellModel: StepCellViewModel {

    let description: String

    let duration: String

    // MARK: - Initialisation

    init(model: StepModel) {
        description = model.instruction
        duration = model.timer.formattedDuration
    }
}
