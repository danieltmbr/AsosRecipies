//
//  DataProvider.swift
//  AsosRecipes
//
//  Created by Daniel Tombor on 2018. 03. 04..
//  Copyright © 2018. danieltmbr. All rights reserved.
//

import RxSwift
import RxCocoa

// MARK: -

protocol RecipesStorage {
    /** Date of the last saving */
    var updatedTime: TimeInterval { get }
    /** Returns the furrent filtered entities */
    func getRecipes(title: String, difficulty: Difficulty, duration: Duration) -> Observable<[RecipeModel]>
    /** Clears the current entities and saves the new ones */
    func overwrite(recipes: [Recipe])
    /** Returns a recipie by id if exists */
    func getRecipe(by id: String) -> RecipeModel?
}

// MARK: -

final class CachingRecipesProvider {

    // MARK: Properties

    /** Local recipe provider */
    private let storage: RecipesStorage
    /** Network recipe provider */
    private let service: RecipesService
    /** Seconds of cache validity (Time to live) */
    private let cacheValidity: TimeInterval
    /** Server or database error */
    private let _error = BehaviorRelay<Error?>(value: nil)
    /** Server request is */
    private let _isLoading = BehaviorRelay<Bool>(value: false)
    /** Disposable subscription container */
    private var serviceBag = DisposeBag()

    // MARK: - Initialisation

    init(storage: RecipesStorage, service: RecipesService, cacheValidity: TimeInterval = 3600) {
        self.storage = storage
        self.service = service
        self.cacheValidity = cacheValidity
    }

    // MARK: - Private methods

    private func loadRecipes(name: String, difficulty: Difficulty, duration: Duration) {
        // Unsubscribe from previous network requests
        serviceBag = DisposeBag()
        // Fetch from network
        service.fetchRecipes()
            .asObservable()
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .utility))
            .subscribe { [weak self] (event) in
                guard let `self` = self else { return }
                switch event {
                case .next(let recipes):
                    self.storage.overwrite(recipes: recipes)
                    self._isLoading.accept(false)
                case .error(let error):
                    self._error.accept(error)
                    self._isLoading.accept(false)
                default: break
                }
            }
            .disposed(by: serviceBag)
    }
}

// MARK: - RecipesProvider

extension CachingRecipesProvider: RecipesProvider {

    var isLoading: Observable<Bool> {
        return _isLoading.asObservable()
    }

    var error: Observable<Error?> {
        return _error.asObservable()
    }

    func fetchRecipes(title: String, difficulty: Difficulty, duration: Duration) -> Observable<[RecipeModel]> {
        // If we're trying to work with outdated entities - refresh
        if storage.updatedTime > cacheValidity {
            loadRecipes(name: title, difficulty: difficulty, duration: duration)
        }
        // Display current recipes anyway
        // - cache is valid:
        //      we need to display from cache
        // - cache is invalid:
        //      we display current data until new is loading
        //      so in case of error we're still displaying cached data
        return storage.getRecipes(title: title, difficulty: difficulty, duration: duration)
    }

    func getRecipe(by id: String) -> RecipeModel? {
        return storage.getRecipe(by: id)
    }
}
