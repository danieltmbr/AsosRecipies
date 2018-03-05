//
//  RecipesListCoordinator.swift
//  AsosRecipes
//
//  Created by Daniel Tombor on 2018. 03. 05..
//  Copyright © 2018. danieltmbr. All rights reserved.
//

import UIKit

// MARK: -

protocol RecipesListCoordinatorProtocol: class {
    func displayRecipe(viewModel: RecipeDetailsViewModel)
}

// MARK: -

final class RecipesListCoordinator: Coordinator {

    // MARK: Properties

    let identifier: UUID = UUID()

    private let window: UIWindow

    private let navigationController = UINavigationController()

    private var childs = [UUID: Coordinator]()

    // MARK: - Initialisation

    init(window: UIWindow) {
        self.window = window
    }

    // MARK: - Public methods

    func start() {
        let difficulties: [Difficulty] = [.any, .rookie, .intermediate, .advanced]
        let durations: [Duration] = [.any, .quick, .medium, .slow]

        let storage = RecipesRealmStorage()
        let service = RecipesServiceClient()
        let dataProvider = CachingRecipesProvider(storage: storage, service: service)
        let viewModel = RecipeListModel(dataProvider: dataProvider, coordinator: self, difficulties: difficulties, durations: durations)
        let listViewController = RecipesListViewController(with: viewModel)

        navigationController.viewControllers = [listViewController]
        window.rootViewController = navigationController
    }
}

// MARK: -

extension RecipesListCoordinator: RecipesListCoordinatorProtocol {

    func displayRecipe(viewModel: RecipeDetailsViewModel) {
        let detailsCoordinator = RecipeDetailsCoordinator(
            viewModel: viewModel,
            navigationController: navigationController,
            parent: self)
        childs[detailsCoordinator.identifier] = detailsCoordinator
        detailsCoordinator.start()
    }
}

// MARK: -

extension RecipesListCoordinator: CoordinatorDelegate {

    func freeCoordinator(with id: UUID) {
        childs.removeValue(forKey: id)
    }
}
