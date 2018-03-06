//
//  ErrorPresenter.swift
//  AsosRecipes
//
//  Created by Daniel Tombor on 2018. 03. 05..
//  Copyright © 2018. danieltmbr. All rights reserved.
//

import UIKit

protocol ErrorPresenter {
    func displayError(_ error: Error)
}

extension ErrorPresenter where Self: UIViewController {

    func displayError(_ error: Error) {
        let message: String = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription

        let alertController = UIAlertController(
            title: "We're really sorry, but".localized(),
            message: message,
            preferredStyle: .alert)

        alertController.addAction(
            UIAlertAction(title: "Never mind".localized(), style: .cancel, handler: nil)
        )

        present(alertController, animated: true, completion: nil)
    }
}
