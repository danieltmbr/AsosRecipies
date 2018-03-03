//
//  IngredientTableViewCell.swift
//  AsosRecipes
//
//  Created by Daniel Tombor on 2018. 02. 28..
//  Copyright © 2018. danieltmbr. All rights reserved.
//

import UIKit

// MARK: -

protocol IngredientCellViewModel {
    /** Name of the ingredient */
    var name: String { get }
    /** Quantity of the ingredient with unit */
    var quantity: String { get }
}

// MARK: -

final class IngredientTableViewCell: UITableViewCell, ExternalCell {

    @IBOutlet weak private var nameLabel: UILabel!

    @IBOutlet weak private var quantityLabel: UILabel!
}

// MARK: -

extension IngredientTableViewCell: ModelRendererCell {

    func render(model: IngredientCellViewModel) {
        nameLabel.text = model.name
        quantityLabel.text = model.quantity
    }
}

