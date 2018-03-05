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

    // MARK: - Properties

    private var appCoordinator: Coordinator!

    // MARK: - Public methods

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        appCoordinator = AppCoordinator(window: UIWindow())
        appCoordinator.start()
        return true
    }
}

