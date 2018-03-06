//
//  RecipeList.swift
//  AsosRecipes
//
//  Created by Daniel Tombor on 2018. 03. 02..
//  Copyright © 2018. danieltmbr. All rights reserved.
//

import RxSwift

protocol RecipesProvider {
    /** Indicates if recipies are being fetched */
    var isLoading: Observable<Bool> { get }
    /** Error occured during getting the recipies */
    var error: Observable<Error?> { get }
    /** Fetching recipies from cache or network */
    func fetchRecipes(title: String, difficulty: Difficulty, duration: Duration) -> Observable<[RecipeModel]>
    /** Get recipes by id */
    func getRecipe(by id: String) -> Observable<RecipeModel>
}

// MARK: -

final class RecipeListModel: RecipeListViewModel {

    // MARK: Properties

    // Enabled durations to choose from
    let durations: [Duration]
    // Enabled difficulties to choose from
    let difficulties: [Difficulty]
    // Coordinator
    private weak var coordinator: RecipesListCoordinatorProtocol?
    // Recipe data provider
    private let dataProvider: RecipesProvider
    // Recipes
    private var recipes = BehaviorSubject<[RecipeCellViewModel]>(value: [])
    // Errors
    private let error = BehaviorSubject<Error?>(value: nil)
    // Search text
    let searchText = BehaviorSubject<String>(value: "")
    // Selected difficulty
    let difficulty = BehaviorSubject<Difficulty>(value: .any)
    // Selected duration
    let duration = BehaviorSubject<Duration>(value: .any)
    // Refresh event
    let refresh = BehaviorSubject<Void>(value: ())
    // Selected recipe id
    let selectRecipeId = BehaviorSubject<String?>(value: nil)
    // Subscription's disposables container
    private let disposeBag = DisposeBag()

    // MARK: - Initialisation

    init(dataProvider: RecipesProvider, coordinator: RecipesListCoordinatorProtocol,
         difficulties: [Difficulty], durations: [Duration]) {
        self.dataProvider = dataProvider
        self.coordinator = coordinator
        self.difficulties = difficulties
        self.durations = durations
        setupBidings()
    }

    // MARK: - Private methods

    private func setupBidings() {

        Observable
            .combineLatest(
                searchText.asObservable().distinctUntilChanged(),
                difficulty.asObservable().distinctUntilChanged(),
                duration.asObservable().distinctUntilChanged(),
                refresh.asObservable()
            )
            .flatMapLatest { [weak self] (title, difficulty, duration, _) -> Observable<[RecipeModel]> in
                guard let `self` = self else { return Observable.just([]) }
                // Fetch data for the conditions
                return self.dataProvider.fetchRecipes(
                    title: title,
                    difficulty: difficulty,
                    duration: duration)
            }
            .map { $0.map { RecipeCellModel(model: $0) } }
            .bind(to: recipes)
            .disposed(by: disposeBag)
        
        selectRecipeId.asObservable()
            .flatMapLatest { [weak self] id -> Observable<RecipeDetailsModel> in
                guard let `self` = self, let id = id
                    else { return Observable.empty() }
                return self.dataProvider
                    .getRecipe(by: id)
                    .map { RecipeDetailsModel(model: $0) }
                    .catchError { (error) -> Observable<RecipeDetailsModel> in
                        self.error.onNext(error)
                        return Observable.empty()
                }
            }
            .subscribe(onNext: { [weak self] (viewModel) in
                guard let `self` = self else { return }
                self.coordinator?.displayRecipe(viewModel: viewModel)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Outputs

extension RecipeListModel {

    var isLoading: Observable<Bool> {
        return dataProvider.isLoading
            .observeOn(MainScheduler.asyncInstance)
    }

    var getRecipes: Observable<[RecipeCellViewModel]> {
        return recipes.share()
    }

    var getError: Observable<Error?> {
        return Observable
            .merge(dataProvider.error, error.asObservable())
            .observeOn(MainScheduler.asyncInstance)
    }

    var getDifficulty: Observable<String> {
        return difficulty.asObserver()
            .distinctUntilChanged()
            .map { $0.title }
            .observeOn(MainScheduler.asyncInstance)
    }

    var getDuration: Observable<String> {
        return duration.asObserver()
            .distinctUntilChanged()
            .map { $0.title }
            .observeOn(MainScheduler.asyncInstance)
    }

    var displayEmptyScreen: Observable<Bool> {
        return Observable
            .combineLatest(recipes.asObservable(), isLoading)
            .map { (recipes, isLoading) in
                return recipes.count <= 0 && !isLoading
            }
            .observeOn(MainScheduler.asyncInstance)
    }
}

// MARK: - Inputs

extension RecipeListModel {

    var setRefresh: AnyObserver<Void> {
        return refresh.asObserver()
    }

    var setSearchText: AnyObserver<String> {
        return searchText.asObserver()
    }

    var setDifficulty: AnyObserver<Difficulty> {
        return difficulty.asObserver()
    }

    var setDuration: AnyObserver<Duration> {
        return duration.asObserver()
    }

    var setSelectRecipeId: AnyObserver<String?> {
        return selectRecipeId.asObserver()
    }
}

// MARK: -

private struct RecipeCellModel: RecipeCellViewModel {

    let id: String

    let title: String

    let coverImageUrl: URL?

    let duration: String

    let ingredientsCount: String

    init(model: RecipeModel) {
        id = model.id
        title = model.title
        coverImageUrl = URL(string: model.imageURL)
        ingredientsCount = "%d ingredients".localized(with: model.ingredients.count)
        let dur = model.steps.reduce(0) { $0 + $1.timer }
        duration = dur.formattedDuration
    }
}
