//
//  IngredientTests.swift
//  AsosRecipiesTests
//
//  Created by Daniel Tombor on 2018. 02. 28..
//  Copyright © 2018. danieltmbr. All rights reserved.
//

import XCTest
@testable import AsosRecipies

class IngredientTests: XCTestCase {

    // MARK: - Test data

    private let ingredientTypesJson: String = """
    [
        "Baking",
        "Condiments",
        "Dairy",
        "Drinks",
        "Meat",
        "Misc",
        "Produce"
    ]
    """

    private let ingredientsJson: String = """
    [
        {
            "quantity": "1 cup",
            "name": "raisins",
            "type": "Produce"
        },
        {
            "quantity": "1",
            "name": "cup water",
            "type": "Drinks"
        },
        {
            "quantity": "3/4 cup",
            "name": "shortening",
            "type": "Baking"
        },
        {
            "quantity": "3",
            "name": "eggs",
            "type": "Dairy"
        }
    ]
    """

    // MARK: - Testh methods
    
    func testIngredientTypesParsing() {
        do {
            let jsonData = ingredientTypesJson.data(using: .utf8)!
            _ = try JSONDecoder().decode([IngredientType].self, from: jsonData)
        } catch let error {
            XCTFail(error.localizedDescription)
        }
    }

    func testIngredientsParsing() {
        do {
            let jsonData = ingredientsJson.data(using: .utf8)!
            _ = try JSONDecoder().decode([Ingredient].self, from: jsonData)
        } catch let error {
            XCTFail(error.localizedDescription)
        }
    }
}
