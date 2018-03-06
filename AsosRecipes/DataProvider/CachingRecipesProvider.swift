//
//  DataProvider.swift
//  AsosRecipes
//
//  Created by Daniel Tombor on 2018. 03. 04..
//  Copyright © 2018. danieltmbr. All rights reserved.
//

import RxSwift

// MARK: -

protocol RecipesStorage {
    /** Date of the last saving */
    var updatedTime: TimeInterval { get }
    /** Returns the furrent filtered entities */
    func getRecipes(title: String, difficulty: Difficulty, duration: Duration) -> Observable<[RecipeModel]>
    /** Clears the current entities and saves the new ones */
    func overwrite(recipes: [Recipe]) -> Observable<Void>
    /** Returns a recipie by id if exists */
    func getRecipe(by id: String) throws -> RecipeModel
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
    private let _error = BehaviorSubject<Error?>(value: nil)
    /** Server request is */
    private let _isLoading = BehaviorSubject<Bool>(value: false)
    /** Disposable subscription container */
    private var serviceBag = DisposeBag()

    // MARK: - Initialisation

    init(storage: RecipesStorage, service: RecipesService, cacheValidity: TimeInterval) {
        self.storage = storage
        self.service = service
        self.cacheValidity = cacheValidity
    }

    // MARK: - Private methods

    private func loadRecipes(name: String, difficulty: Difficulty, duration: Duration) {
        // Unsubscribe from previous network requests
        serviceBag = DisposeBag()
        // Fetch from network
        _isLoading.onNext(true)
        service.fetchRecipes()
            .asObservable()
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .utility))
            .catchError { [weak self] (error) -> Observable<[Recipe]> in
                self?._error.onNext(NetworkError.cannotLoadRecipes(error))
                return Observable.empty()
            }
            .flatMapLatest { [weak self] recipes -> Observable<Void> in
                guard let `self` = self
                    else { return Observable.empty() }
                return self.storage
                    .overwrite(recipes: recipes)
                    .catchError { (error) -> Observable<Void> in
                        self._error.onNext(error)
                        return Observable.empty()
                    }
            }
            .subscribe { [weak self] _ in
                self?._isLoading.onNext(false)
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
        let updatedDate = Date(timeIntervalSince1970: storage.updatedTime)
        let difference = abs(Date().timeIntervalSince(updatedDate))
        if difference > cacheValidity {
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

    func getRecipe(by id: String) -> Observable<RecipeModel> {
        return Observable.create { [weak self] observer in
            guard let `self` = self else {
                observer.onCompleted()
                return Disposables.create()
            }
            do {
                let recipe = try self.storage.getRecipe(by: id)
                observer.onNext(recipe)
                observer.onCompleted()
            } catch let error {
                observer.onError(error)
            }
            return Disposables.create()
        }
    }
}
