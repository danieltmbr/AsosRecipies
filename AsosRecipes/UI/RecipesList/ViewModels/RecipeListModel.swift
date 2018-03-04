//
//  RecipeList.swift
//  AsosRecipes
//
//  Created by Daniel Tombor on 2018. 03. 02..
//  Copyright © 2018. danieltmbr. All rights reserved.
//

import RxSwift
import RxCocoa

protocol RecipesProvider {
    /** Indicates if recipies are being fetched */
    var isLoading: Observable<Bool> { get }
    /** Error occured during getting the recipies */
    var error: Observable<Error?> { get }
    /** Fetching recipies from cache or network */
    func fetchRecipes(title: String, difficulty: Difficulty, duration: Duration) -> Observable<[RecipeModel]>
}

// MARK: -

final class RecipeListModel {

    // MARK: Properties

    // Recipe data provider
    private let dataProvider: RecipesProvider
    // Enabled durations to choose from
    let durations: [Duration]
    // Enabled difficulties to choose from
    let difficulties: [Difficulty]
    // Search text
    let searchText = BehaviorRelay<String>(value: "")
    // Selected difficulty
    let difficulty = BehaviorRelay<Difficulty>(value: .any)
    // Selected duration
    let duration = BehaviorRelay<Duration>(value: .any)
    // Subscription's disposables container
    private let disposeBag = DisposeBag()

    // MARK: - Initialisation

    init(dataProvider: RecipesProvider, difficulties: [Difficulty], durations: [Duration]) {
        self.dataProvider = dataProvider
        self.difficulties = difficulties
        self.durations = durations
    }
}

// MARK: -

extension RecipeListModel: RecipeListViewModel {

    var isLoading: Observable<Bool> {
        return dataProvider.isLoading
    }

    var recipes: Observable<[RecipeCellViewModel]> {
        return Observable
            .combineLatest(
                searchText.asObservable(),
                difficulty.asObservable(),
                duration.asObservable())
            .asObservable()
            .flatMapLatest { [weak self] (title, difficulty, duration) -> Observable<[RecipeModel]> in
                guard let `self` = self else { return Observable.just([]) }
                return self.dataProvider.fetchRecipes(
                    title: title,
                    difficulty: difficulty,
                    duration: duration)
            }
            .map { $0.map { RecipeCellModel(model: $0) } }
    }

    var error: Observable<Error?> {
        return dataProvider.error
    }
}

// MARK: -

private struct RecipeCellModel: RecipeCellViewModel {

    let title: String

    let coverImageUrl: URL?

    let duration: String

    let ingredientsCount: String

    init(model: RecipeModel) {
        title = model.title
        coverImageUrl = URL(string: model.imageURL)
        ingredientsCount = "%d ingredients".localized(with: model.ingredients.count)

        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.hour, .minute]

        let dur = model.steps.reduce(0) { $0 + $1.timer }
        duration = formatter.string(from: TimeInterval(dur * 60))
            ?? "%d minute(s)".localized(with: dur)
    }
}
