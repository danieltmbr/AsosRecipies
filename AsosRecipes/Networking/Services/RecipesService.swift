//
//  RecipesService.swift
//  AsosRecipes
//
//  Created by Daniel Tombor on 2018. 03. 03..
//  Copyright © 2018. danieltmbr. All rights reserved.
//

import RxSwift
import Moya

// MARK: -

protocol RecipesService {
    func fetchRecipes() -> Single<[Recipe]>
}

// MARK: -

final class RecipesServiceClient {

    // MARK: Properties

    private let provider: MoyaProvider<RecipesEndpoints>

    // MARK: - Initialisation

    init(provider: MoyaProvider<RecipesEndpoints> = MoyaProvider<RecipesEndpoints>()) {
        self.provider = provider
    }
}

// MARK: -

extension RecipesServiceClient: RecipesService {

    func fetchRecipes() -> Single<[Recipe]> {
        return provider.rx
            .request(.all)
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .utility))
            .map([Recipe].self)
    }
}
