//
//  RecipesService.swift
//  AsosRecipes
//
//  Created by Daniel Tombor on 2018. 03. 03..
//  Copyright © 2018. danieltmbr. All rights reserved.
//

import RxSwift
import Moya
import Alamofire

// MARK: -

protocol RecipesService {
    func fetchRecipes() -> Single<[Recipe]>
}

// MARK: -

final class RecipesServiceClient {

    // MARK: Properties

    private let provider: MoyaProvider<RecipesEndpoints>

    // MARK: - Initialisation

    init(provider: MoyaProvider<RecipesEndpoints>) {
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

// MARK: -

extension RecipesServiceClient {

    class func defaultManager() -> Manager {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = Manager.defaultHTTPHeaders
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.timeoutIntervalForRequest = 8

        let manager = Manager(configuration: configuration)
        manager.retrier = RetryManager(count: 1)
        manager.startRequestsImmediately = false
        return manager
    }
}

// MARK: -

private struct RetryManager: RequestRetrier {

    let count: Int

    func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {
        completion(request.retryCount <= count, 1)
    }
}
