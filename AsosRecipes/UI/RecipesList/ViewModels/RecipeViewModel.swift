//
//  RecipeViewModel.swift
//  AsosRecipes
//
//  Created by Daniel Tombor on 2018. 03. 03..
//  Copyright © 2018. danieltmbr. All rights reserved.
//

import Foundation

protocol RecipeViewModel {
    /** Local identifier */
    var id: String { get }
    /** Title of the recipe */
    var title: String { get }
    /** String of a cover image's url */
    var coverImageUrl: URL? { get }
}
