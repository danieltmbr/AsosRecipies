//
//  RecipesServiceTests.swift
//  AsosRecipesTests
//
//  Created by Daniel Tombor on 2018. 03. 04..
//  Copyright © 2018. danieltmbr. All rights reserved.
//

import XCTest
import Moya
import RxSwift
@testable import AsosRecipes

class RecipesServiceTests: XCTestCase {

    let disposeBag = DisposeBag()
    
    func testFetchRecipes() {
        let provider = MoyaProvider<RecipesEndpoints>(stubClosure: MoyaProvider.immediatelyStub)
        let service = RecipesServiceClient(provider: provider)
        let exp = expectation(description: "testFetchRecipes")
        service.fetchRecipes()
            .asObservable()
            .subscribe(
                onNext: { (_) in exp.fulfill() },
                onError: { (_) in XCTFail() }
            )
            .disposed(by: disposeBag)
        waitForExpectations(timeout: 1)
    }
}
