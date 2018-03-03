//
//  AppDelegate.swift
//  AsosRecipies
//
//  Created by Daniel Tombor on 2018. 02. 28..
//  Copyright © 2018. danieltmbr. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        window = UIWindow()
        window?.makeKeyAndVisible()

        let difficulties: [Difficulty] = [.any, .rookie, .intermediate, .advanced]
        let durations: [Duration] = [.any, .quick, .medium, .slow]
        let viewModel = RecipeListModel(difficulties: difficulties, durations: durations)
        let listViewController = RecipesListViewController(with: viewModel)

        window?.rootViewController =  UINavigationController(rootViewController: listViewController)

        return true
    }
}

