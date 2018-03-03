//
//  RecipeTests.swift
//  AsosRecipiesTests
//
//  Created by Daniel Tombor on 2018. 02. 28..
//  Copyright © 2018. danieltmbr. All rights reserved.
//

import XCTest
@testable import AsosRecipes

class RecipeTests: XCTestCase {

    // MARK: - Test data

    private let recipeJson: String = """
    {
        "name": "Cranberry and Apple Stuffed Acorn Squash Recipe",
        "ingredients": [
            {
                "quantity": "2",
                "name": "acorn squash",
                "type": "Produce"
            },
            {
                "quantity": "1",
                "name": "boiling water",
                "type": "Drinks"
            },
            {
                "quantity": "2",
                "name": "apples chopped into 1.4 inch pieces",
                "type": "Produce"
            },
            {
                "quantity": "1/2 cup",
                "name": "dried cranberries",
                "type": "Produce"
            },
            {
                "quantity": "1 teaspoon",
                "name": "cinnamon",
                "type": "Baking"
            },
            {
                "quantity": "2 tablespoons",
                "name": "melted butter",
                "type": "Dairy"
            }
        ],
        "steps": [
            "Cut squash in half, remove seeds.",
            "Place squash in baking dish, cut-side down.",
            "Pour 1/4-inch water into dish.",
            "Bake for 30 minutes at 350 degrees F.",
            "In large bowl, combine remaining ingredients.",
            "Remove squash from oven, fill with mix.",
            "Bake for 30-40 more minutes, until squash tender.",
            "Enjoy!"
        ],
        "timers": [
            0,
            0,
            0,
            30,
            0,
            0,
            30,
            0
        ],
        "imageURL": "http://elanaspantry.com/wp-content/uploads/2008/10/acorn_squash_with_cranberry.jpg",
        "originalURL": ""
    }
    """

    private let recipeWithNoOriginalUrlJson: String = """
    {
        "name": "Curried Lentils and Rice",
        "ingredients": [
            {
                "quantity": "1 quart",
                "name": "beef broth",
                "type": "Misc"
            },
            {
                "quantity": "1 cup",
                "name": "dried green lentils",
                "type": "Misc"
            }
        ],
        "steps": [
            "Cook lentils for 20 minutes.",
            "Add rice and simmer for 20 minutes."
        ],
        "timers": [
            20,
            20
        ],
        "imageURL": "http://dagzhsfg97k4.cloudfront.net/wp-content/uploads/2012/05/lentils3.jpg"
    }
    """

    // MARK: - Test methods

    func testRecipeParsing() {
        do {
            let jsonData = recipeJson.data(using: .utf8)!
            _ = try JSONDecoder().decode(Recipe.self, from: jsonData)
        } catch let error {
            XCTFail(error.localizedDescription)
        }
    }

    func testRecipeParsingWithMissingOptionalParam() {
        do {
            let jsonData = recipeWithNoOriginalUrlJson.data(using: .utf8)!
            _ = try JSONDecoder().decode(Recipe.self, from: jsonData)
        } catch let error {
            XCTFail(error.localizedDescription)
        }
    }
}
