//
//  RecipeDetailsCoordinator.swift
//  AsosRecipes
//
//  Created by Daniel Tombor on 2018. 03. 05..
//  Copyright © 2018. danieltmbr. All rights reserved.
//

import UIKit

// MARK: -

protocol DismissDelegate: class {
    func dismissed(viewController: UIViewController)
}

// MARK: -

protocol CoordinatorDelegate: class {
    func freeCoordinator(with id: UUID)
}

// MARK: -

final class RecipeDetailsCoordinator: Coordinator {

    // MARK: Properties

    let identifier: UUID = UUID()

    private let navigationController: UINavigationController

    private let viewModel: RecipeDetailsViewModel

    private weak var parent: CoordinatorDelegate?

    // MARK: - Initialisation

    init(viewModel: RecipeDetailsViewModel, navigationController: UINavigationController, parent: CoordinatorDelegate) {
        self.viewModel = viewModel
        self.navigationController = navigationController
        self.parent = parent
    }

    // MARK: - Public methods

    func start() {
        let detailsViewController = RecipeDetailsViewController(with: viewModel, delegate: self)
        navigationController.pushViewController(detailsViewController, animated: true)
    }
}

// MARK: -

extension RecipeDetailsCoordinator: DismissDelegate {

    func dismissed(viewController: UIViewController) {
        parent?.freeCoordinator(with: identifier)
    }
}
