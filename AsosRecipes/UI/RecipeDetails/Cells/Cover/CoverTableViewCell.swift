//
//  CoverTableViewCell.swift
//  AsosRecipes
//
//  Created by Daniel Tombor on 2018. 03. 03..
//  Copyright © 2018. danieltmbr. All rights reserved.
//

import UIKit
import Kingfisher

final class CoverTableViewCell: UITableViewCell, ExternalCell {

    @IBOutlet weak private var coverImageView: UIImageView!

    @IBOutlet weak private var titleLabel: UILabel!
}

// MARK: -

extension CoverTableViewCell: ModelRendererCell {

    func render(model: RecipeViewModel) {
        coverImageView.kf.setImage(with: model.coverImageUrl)
        titleLabel.text = model.title
    }
}
