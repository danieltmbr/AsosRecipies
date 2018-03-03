//
//  OptionsPresenter.swift
//  AsosRecipes
//
//  Created by Daniel Tombor on 2018. 03. 03..
//  Copyright © 2018. danieltmbr. All rights reserved.
//

import RxSwift

// MARK: -

protocol OptionsPresenter {
    func presentOptions<T: CustomStringConvertible>(title: String, options: [T]) -> Observable<T>
}

// MARK: -

extension OptionsPresenter where Self: UIViewController {

    func presentOptions<T: CustomStringConvertible>(title: String, options: [T]) -> Observable<T> {

        return Observable.create { [weak self] observer in
            guard let `self` = self else {
                observer.onCompleted()
                return Disposables.create()
            }

            let actionSheet = UIAlertController(
                title: title,
                message: nil,
                preferredStyle: .actionSheet)

            for option in options {
                let action = UIAlertAction(
                    title: option.description,
                    style: .default) { (_) in
                        observer.onNext(option)
                }
                actionSheet.addAction(action)
            }

            self.present(actionSheet, animated: true, completion: nil)
            return Disposables.create {
                actionSheet.dismiss(animated: true, completion: nil)
            }
        }
    }
}
