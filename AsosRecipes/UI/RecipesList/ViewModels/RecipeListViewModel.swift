//
//  RecipeList.swift
//  AsosRecipes
//
//  Created by Daniel Tombor on 2018. 03. 02..
//  Copyright © 2018. danieltmbr. All rights reserved.
//

import RxSwift
import RxCocoa

// MARK: -

enum Difficulty: CustomStringConvertible {
    case rookie, intermediate, advanced, any

    var title: String {
        switch self {
        case .rookie: return "difficulty.rookie".localized(comment: "Title for 'rookie difficulty' button")
        case .intermediate: return "difficulty.intermediate".localized(comment: "Title for 'intermediate difficulty' button")
        case .advanced: return "difficulty.advanced".localized(comment: "Title for 'advanced difficulty' button")
        case .any: return "difficulty.any".localized(comment: "Title for 'any difficulty' button")
        }
    }

    var description: String {
        return title
    }
}

// MARK: -

enum Duration : CustomStringConvertible {
    /** 0 - 10 minutes */
    case quick
    /** 10 - 20 minutes */
    case medium
    /** > 20 minutes */
    case slow
    /** from zero to infinity */
    case any

    var title: String {
        switch self {
        case .quick: return "duration.quick".localized(comment: "Title for 'quick duration' button")
        case .medium: return "duration.medium".localized(comment: "Title for 'medium duration' button")
        case .slow: return "duration.slow".localized(comment: "Title for 'slow duration' button")
        case .any: return "duration.any".localized(comment: "Title for 'any duration' button")
        }
    }

    var description: String {
        return title
    }
}

// MARK: -

final class RecipeListModel {

    // MARK: Properties

    private let _isLoading = BehaviorSubject<Bool>(value: false)

    private let _recipes = BehaviorRelay<[RecipeCellViewModel]>(value: [])

    private let _error = BehaviorRelay<Error?>(value: nil)

    let searchText = BehaviorRelay<String>(value: "")

    let difficulty = BehaviorRelay<Difficulty>(value: .any)

    let duration = BehaviorRelay<Duration>(value: .any)

    let durations: [Duration]

    let difficulties: [Difficulty]

    // MARK: - Initialisation

    init(difficulties: [Difficulty], durations: [Duration]) {
        self.difficulties = difficulties
        self.durations = durations
    }

    // MARK: - Methods

}

// MARK: -

extension RecipeListModel: RecipeListViewModel {

    var isLoading: Observable<Bool> {
        return _isLoading.asObserver()
    }

    var recipes: Observable<[RecipeCellViewModel]> {
        return _recipes.asObservable()
    }

    var error: Observable<Error?> {
        return _error.asObservable()
    }
}
