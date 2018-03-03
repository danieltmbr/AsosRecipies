//
//  RecipesListViewController.swift
//  AsosRecipies
//
//  Created by Daniel Tombor on 2018. 02. 28..
//  Copyright © 2018. danieltmbr. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

// MARK: -

protocol RecipeListViewModel {

    // MARK: Outputs

    /** Indicates if recipies are being fetched */
    var isLoading: Observable<Bool> { get }
    /** Current recipies */
    var recipes: Observable<[RecipeCellViewModel]> { get }
    /** Some error occured */
    var error: Observable<Error?> { get }
    /** Selectable difficulties */
    var difficulties: [Difficulty] { get }
    /** Selectable durations */
    var durations: [Duration] { get }

    // MARK: In/Out

    /** Search text */
    var searchText: BehaviorRelay<String> { get }
    /** Difficulty of the recipe */
    var difficulty: BehaviorRelay<Difficulty> { get }
    /** Duration of the recipe */
    var duration: BehaviorRelay<Duration> { get }
}

// MARK: -

private struct Constants {
    /** Spacing between cells and rows */
    let spacing: CGFloat = 1
    /** Aspect ratio of cell (width:height) */
    let aspectRatio: CGFloat = 0.7
    /** SearchBar's placeholder text */
    let searchBarPlaceholder = "Search by name".localized(comment: "SearchBar's placeholder text.")
}

// MARK: -

final class RecipesListViewController: UIViewController, OptionsPresenter {

    // MARK: - Properties

    /** Constant values */
    private let constants = Constants()
    /** Business logic */
    private let viewModel: RecipeListViewModel
    /** Search bar displayed in the navigaton bar */
    private let searchBar = UISearchBar()
    /** Disposables collector */
    private let disposeBag = DisposeBag()

    // MARK: - IBOutlets

    @IBOutlet weak private var durationButton: UIButton!

    @IBOutlet weak private var difficultyButton: UIButton!
    /** Recipes collection view */
    @IBOutlet weak private var collectionView: UICollectionView!

    // MARK: - Initialisation methods

    init(with viewModel: RecipeListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "RecipesListViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle methods

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupSearchBar()
        setupCollectionView()
        setupBindings()
    }

    // MARK: - Private methods

    private func setupNavigationBar() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = .groupTableViewBackground
        navigationController?.navigationBar.shadowImage = UIImage()
    }

    private func setupSearchBar() {
        navigationItem.titleView = searchBar
        searchBar.placeholder = constants.searchBarPlaceholder
    }

    private func setupCollectionView() {
        collectionView.registerCell(RecipeCollectionViewCell.self)
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumLineSpacing = constants.spacing
            layout.minimumInteritemSpacing = constants.spacing
        }
    }

    private func setupBindings() {

        // Bind searchbar to viewmodel's search text input
        searchBar.rx.text
            .orEmpty
            .debounce(0.2, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .bind(to: viewModel.searchText)
            .disposed(by: disposeBag)

        // Bind recipies to the collectionView
        viewModel.recipes
            .bind(to: collectionView.rx.items(
                cellIdentifier: RecipeCollectionViewCell.identifier,
                cellType: RecipeCollectionViewCell.self)
            ) { (item, model, cell) in
                cell.render(model: model)
            }
            .disposed(by: disposeBag)


        // Bind item selection action
        // TODO: Navigate at didSelect

        // Bind difficulty button title
        viewModel.difficulty.asObservable()
            .map { $0.title }
            .bind(to: difficultyButton.rx.title(for: .normal))
            .disposed(by: disposeBag)

        // Bind duration button tap
        difficultyButton.rx.tap
            .asObservable()
            .observeOn(MainScheduler.instance)
            .flatMap { [unowned self] in
                self.presentOptions(
                    title: "Select difficulty".localized(comment: "Difficulty selector's title"),
                    options: self.viewModel.difficulties
                )
            }
            .bind(to: viewModel.difficulty)
            .disposed(by: disposeBag)


        // Bind duration button title
        viewModel.duration.asObservable()
            .map { $0.title }
            .bind(to: durationButton.rx.title(for: .normal))
            .disposed(by: disposeBag)

        // Bind duration button tap 
        durationButton.rx.tap
            .asObservable()
            .observeOn(MainScheduler.instance)
            .flatMap { [unowned self] in
                self.presentOptions(
                    title: "Select duration".localized(comment: "Duration selector's title"),
                    options: self.viewModel.durations
                )
            }
            .bind(to: viewModel.duration)
            .disposed(by: disposeBag)
    }
}

// MARK: -

extension RecipesListViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width - constants.spacing
        let height = width / constants.aspectRatio
        return CGSize(width: width, height: height)
    }
}

// MARK: -

extension RecipesListViewController: UICollectionViewDataSourcePrefetching {

    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        // ImagePrefetcher(urls: [URL]()).start()
    }
}
