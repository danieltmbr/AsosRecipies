//
//  RecipeCollectionViewCell.swift
//  AsosRecipes
//
//  Created by Daniel Tombor on 2018. 02. 28..
//  Copyright © 2018. danieltmbr. All rights reserved.
//

import UIKit
import Kingfisher

// MARK: -

protocol RecipeCellViewModel: RecipeViewModel {
    /** Number of the ingredients */
    var ingredientsCount: String { get }
    /** Duration of the steps */
    var duration: String { get }
}

// MARK: -

final class RecipeCollectionViewCell: UICollectionViewCell, ExternalCell {

    // MARK: IBOutlets

    @IBOutlet weak private var coverImageView: UIImageView!

    @IBOutlet weak private var titleLabel: UILabel!

    @IBOutlet weak private var ingredientsLabel: UILabel!

    @IBOutlet weak private var durationLabel: UILabel!

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.2) { [weak self] in
                guard let `self` = self else { return }
                let scale: CGFloat = 0.97
                self.transform = self.isHighlighted
                    ? CGAffineTransform(scaleX: scale, y: scale)
                    : .identity
            }
        }
    }

    // MARK: - Public methods

    func render(model: RecipeCellViewModel) {
        let processor = ResizingImageProcessor(referenceSize: bounds.size, mode: .aspectFill)
        coverImageView.kf.setImage(with: model.coverImageUrl, options: [.processor(processor)])
        titleLabel.text = model.title
        ingredientsLabel.text = model.ingredientsCount
        durationLabel.text = model.duration
    }
}
