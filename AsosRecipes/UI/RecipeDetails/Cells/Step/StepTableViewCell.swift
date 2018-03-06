//
//  StepTableViewCell.swift
//  AsosRecipes
//
//  Created by Daniel Tombor on 2018. 02. 28..
//  Copyright © 2018. danieltmbr. All rights reserved.
//

import UIKit

// MARK: -

protocol StepCellViewModel {
    /** Description of the step */
    var description: String { get }
    /** Time consumption of the step */
    var duration: String { get }
}

// MARK: -

final class StepTableViewCell: UITableViewCell, ExternalCell {

    @IBOutlet weak private var descriptionLabel: UILabel!

    @IBOutlet weak private var durationLabel: UILabel!
}

// MARK: -

extension StepTableViewCell: ModelRendererCell {

    func render(model: StepCellViewModel) {
        descriptionLabel.text = model.description
        durationLabel.text = model.duration
        durationLabel.isHidden = model.duration.isEmpty
    }
}
