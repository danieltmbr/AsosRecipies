//
//  IngredientModel.swift
//  AsosRecipes
//
//  Created by Daniel Tombor on 2018. 03. 04..
//  Copyright © 2018. danieltmbr. All rights reserved.
//

import RealmSwift

final class IngredientModel: Object {
    /** Name of the ingredient */
    @objc dynamic var name: String = ""
    /** Quantity (with unit) of the ingredient */
    @objc dynamic var quantity: String = ""
    /** Type of ingredient */
    @objc dynamic var type: String = ""
}
