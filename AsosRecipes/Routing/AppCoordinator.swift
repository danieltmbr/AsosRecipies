//
//  AppCoordinator.swift
//  AsosRecipes
//
//  Created by Daniel Tombor on 2018. 03. 05..
//  Copyright © 2018. danieltmbr. All rights reserved.
//

import UIKit

// MARK: -

protocol Coordinator: class {

    var identifier: UUID { get }

    func start()
}

// MARK: -

final class AppCoordinator: Coordinator {

    // MARK: Properties

    let identifier: UUID = UUID()

    private let window: UIWindow

    private var childs = [UUID: Coordinator]()

    // MARK: - Initialisation

    init(window: UIWindow) {
        self.window = window
    }

    // MARK: - Public methodsr

    func start() {
        let listCoordinator = RecipesListCoordinator(window: window)
        listCoordinator.start()
        childs[listCoordinator.identifier] = listCoordinator
        window.makeKeyAndVisible()
    }
}
