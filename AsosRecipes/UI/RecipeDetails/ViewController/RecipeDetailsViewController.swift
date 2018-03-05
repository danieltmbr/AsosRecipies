//
//  RecipeDetailsViewController.swift
//  AsosRecipies
//
//  Created by Daniel Tombor on 2018. 02. 28..
//  Copyright © 2018. danieltmbr. All rights reserved.
//

import UIKit
import RxSwift

// MARK: -

protocol RecipeDetailsViewModel: RecipeViewModel {
    /** Collection of ingredients */
    var ingredients: [IngredientCellViewModel] { get }
    /** Collection of steps */
    var steps: [StepCellViewModel] { get }
}

// MARK: -

private enum RecipeDetailSection: Int {

    case cover = 0, ingredient, steps, count

    var title: String? {
        switch self {
        case .ingredient: return "Ingredients"
        case .steps: return "Steps"
        default: return nil
        }
    }

    var height: CGFloat {
        switch self {
        case .ingredient, .steps: return 28
        default: return 0
        }
    }
}

// MARK: -

final class RecipeDetailsViewController: UIViewController, URLSessionDelegate {

    // MARK: Properties

    /** Data */
    private let viewModel: RecipeDetailsViewModel
    /** Dismiss delegate */
    private weak var delegate: DismissDelegate?

    // MARK: - IBOutlets

    /** Details tableView */
    @IBOutlet weak private var tableView: UITableView!

    // MARK: - Initialisation methods

    init(with viewModel: RecipeDetailsViewModel, delegate: DismissDelegate) {
        self.viewModel = viewModel
        self.delegate = delegate
        super.init(nibName: "RecipeDetailsViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle methods

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
//        navigationController?.navigationBar.isTranslucent = true
//        navigationController?.navigationBar.barTintColor = .clear
//        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if !(navigationController?.viewControllers.contains(self) ?? false) {
            delegate?.dismissed(viewController: self)
        }
    }

    // MARK: - Private methods

    private func setupTableView() {
        tableView.register(externalCell: CoverTableViewCell.self)
        tableView.register(externalCell: IngredientTableViewCell.self)
        tableView.register(externalCell: StepTableViewCell.self)
    }
}

// MARK: -

extension RecipeDetailsViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return RecipeDetailSection.count.rawValue
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = RecipeDetailSection(rawValue: section)
            else { return 0 }
        switch section {
        case .cover: return 1
        case .ingredient: return viewModel.ingredients.count
        case .steps: return viewModel.steps.count
        default: return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = RecipeDetailSection(rawValue: indexPath.section)
            else { fatalError("Plese check the number of sections") }

        switch section {
        case .cover:
            return tableView.getCell(of: CoverTableViewCell.self,
                                     for: indexPath,
                                     with: viewModel)
        case .ingredient:
            return tableView.getCell(of: IngredientTableViewCell.self,
                                     for: indexPath,
                                     with: viewModel.ingredients[indexPath.row])
        case .steps:
            return tableView.getCell(of: StepTableViewCell.self,
                                     for: indexPath,
                                     with: viewModel.steps[indexPath.row])
        default:
            fatalError("Plese check the number of sections")
        }
    }
}

// MARK: -

extension RecipeDetailsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return RecipeDetailSection(rawValue: section)?.height ?? 0
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let section = RecipeDetailSection(rawValue: section),
            (section == .ingredient || section == .steps),
            let headerView = SectionHeaderView.loadFromNib()
            else { return nil }
        headerView.titleLabel.text = section.title
        return headerView
    }
}
