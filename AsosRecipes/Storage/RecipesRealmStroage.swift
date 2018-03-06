//
//  CacheStorage.swift
//  AsosRecipes
//
//  Created by Daniel Tombor on 2018. 03. 04..
//  Copyright © 2018. danieltmbr. All rights reserved.
//

import Foundation
import RealmSwift
import RxRealm
import RxSwift


final class RecipesRealmStorage: RecipesStorage {

    private let updateKey: String = "RecipesRealmStorage.UpdatedTime"

    // MARK: - Properties

    var updatedTime: TimeInterval {
        get {
            // .double(for key: ) returns 0 if not exists -> No good
            guard let updatedTime = UserDefaults.standard.value(forKey: updateKey) as? Double
                else { return .greatestFiniteMagnitude }
            return updatedTime
        }
        set {
            UserDefaults.standard.set(newValue, forKey: updateKey)
            UserDefaults.standard.synchronize()
        }
    }

    // MARK: - Public methods

    func getRecipes(title: String, difficulty: Difficulty, duration: Duration) -> Observable<[RecipeModel]> {
        guard let realm = try? Realm()
            else { return Observable.error(DatabaseError.cannotOpenDatabase) }

        let predicate = NSPredicate(
            format: """
                title LIKE[c] %@ AND
                difficulty >= %lf AND difficulty < %lf AND
                steps.@sum.timer >= %d AND steps.@sum.timer < %d
            """,
            title+"*", difficulty.min, difficulty.max, duration.min, duration.max)

        let recipes = realm
            .objects(RecipeModel.self)
            .filter(predicate)

        return Observable
            .changeset(from: recipes)
            .map { Array($0.0) }
    }

    func getRecipe(by id: String) throws -> RecipeModel {
        guard let realm = try? Realm()
            else { throw DatabaseError.cannotOpenDatabase }
        guard let recipe = realm.object(ofType: RecipeModel.self, forPrimaryKey: id)
            else { throw DatabaseError.cannotFindRecipe }
        return recipe
    }

    func overwrite(recipes: [Recipe]) -> Observable<Void> {
        return Observable.create{ [weak self] observer in
            guard let `self` = self else {
                observer.onCompleted()
                return Disposables.create()
            }
            guard let realm = try? Realm() else {
                observer.onError(DatabaseError.cannotOpenDatabase)
                return Disposables.create()
            }

            let recipeModels = recipes.map(self.mapRecipe)
            self.setRelativeDifficulties(for: recipeModels)
            do {
                try realm.write {
                    realm.deleteAll()
                    realm.add(recipeModels)
                    self.updatedTime = Date().timeIntervalSince1970
                }
                observer.onCompleted()
            } catch let error {
                observer.onError(DatabaseError.cannotWriteToDatabase(error))
            }
            return Disposables.create()
        }
    }

    // MARK: - Private methods

    private func setRelativeDifficulties(for recipes: [RecipeModel]) {
        var easiest: Double = .greatestFiniteMagnitude
        var hardest: Double = 0
        // Calculate absolute difficulties
        recipes.forEach {
            let stepsWeight = pow(Double($0.steps.count), 2)
            let ingredientsWeight = pow(Double($0.ingredients.count), 2)
            let dif = sqrt(stepsWeight + ingredientsWeight)
            $0.difficulty = dif
            easiest = min(dif, easiest)
            hardest = max(dif, hardest)
        }
        // Normalise difficulties: 0 to 1
        let interval = hardest - easiest
        recipes.forEach {
            $0.difficulty = ($0.difficulty-easiest)/interval
        }
    }
}

// MARK: - Private mapping methods

private extension RecipesRealmStorage {

    func mapRecipe(_ recipe: Recipe) -> RecipeModel {
        let model = RecipeModel()
        model.title = recipe.name
        model.imageURL = recipe.imageURL.absoluteString
        model.originalURL = recipe.originalURL ?? ""

        let ingredients: [IngredientModel] = recipe.ingredients.map(mapIngredient)
        let steps: [StepModel] = zip(recipe.steps, recipe.timers).map(mapStep)
        model.ingredients.append(objectsIn: ingredients)
        model.steps.append(objectsIn: steps)
        
        return model
    }

    func mapIngredient(_ ingredient: Ingredient) -> IngredientModel {
        let model = IngredientModel()
        model.name = ingredient.name
        model.quantity = ingredient.quantity
        model.type = ingredient.type.rawValue
        return model
    }

    func mapStep(_ instruction: String, _ timer: Int) -> StepModel {
        let model = StepModel()
        model.instruction = instruction
        model.timer = timer
        return model
    }
}

// MARK: -

private extension Difficulty {

    /** Minimum boundary value to filter by */
    var min: Double {
        switch self {
        case .intermediate: return 1/3
        case .advanced: return 2/3
        default: return 0
        }
    }

    /** Maximum boundary value to filter by */
    var max: Double {
        switch self {
        case .rookie: return 1/3
        case .intermediate: return 2/3
        default: return .greatestFiniteMagnitude
        }
    }
}

// MARK: -

private extension Duration {

    /** Minimum boundary value to filter by */
    var min: Int {
        switch self {
        case .medium: return 10
        case .slow: return 20
        default: return 0
        }
    }

    /** Maximum boundary value to filter by */
    var max: Int {
        switch self {
        case .quick: return 10
        case .medium: return 20
        // TECHDEBT: - Find a better solution
        // It's temporary, because Int.max did not work with predicate.
        default: return 1000
        }
    }
}
