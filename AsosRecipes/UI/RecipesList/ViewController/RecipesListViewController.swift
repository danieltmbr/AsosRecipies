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

    /** Selectable difficulties */
    var difficulties: [Difficulty] { get }
    /** Selectable durations */
    var durations: [Duration] { get }

    /** Indicates if recipies are being fetched */
    var isLoading: Observable<Bool> { get }
    /** Current recipies */
    var getRecipes: Observable<[RecipeCellViewModel]> { get }
    /** Some error occured */
    var getError: Observable<Error?> { get }
    /** Difficulty of the recipe */
    var getDifficulty: Observable<String> { get }
    /** Duration of the recipe */
    var getDuration: Observable<String> { get }
    /** Display empty screen */
    var displayEmptyScreen: Observable<Bool> { get }

    // MARK: Inputs

    /** Refresh signal */
    var setRefresh: AnyObserver<Void> { get }
    /** Search text */
    var setSearchText: AnyObserver<String> { get }
    /** Difficulty of the recipe */
    var setDifficulty: AnyObserver<Difficulty> { get }
    /** Duration of the recipe */
    var setDuration: AnyObserver<Duration> { get }
    /** Selected model id */
    var setSelectRecipeId: AnyObserver<String?> { get }
}

// MARK: -

private struct Constants {
    /** Margins */
    let margins = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
    /** Spacing between cells and rows */
    let spacing: CGFloat = 8
    /** Aspect ratio of cell (width:height) */
    let aspectRatio: CGFloat = 0.8
    /** SearchBar's placeholder text */
    let searchBarPlaceholder = "Search by name".localized(comment: "SearchBar's placeholder text.")
}

// MARK: -

final class RecipesListViewController: UIViewController, OptionsPresenter, ErrorPresenter {

    // MARK: - Properties

    /** Constant values */
    private let constants = Constants()
    /** Business logic */
    private let viewModel: RecipeListViewModel
    /** Search bar displayed in the navigaton bar */
    private let searchBar = UISearchBar()
    /** Disposables collector */
    private let disposeBag = DisposeBag()
    /** Refresh control */
    private let refreshControl = UIRefreshControl()

    // MARK: - IBOutlets

    /** Recipes collection view */
    @IBOutlet weak private var collectionView: UICollectionView!

    @IBOutlet weak private var durationButton: UIButton!

    @IBOutlet weak private var difficultyButton: UIButton!

    @IBOutlet weak private var emptyIndicatorView: UIView!

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

    // MARK: - IBActions

    @IBAction private func handleEmptyViewTap(_ sender: UITapGestureRecognizer) {
        searchBar.endEditing(true)
        viewModel.setRefresh.onNext(())
    }
    
    // MARK: - Private methods

    private func setupNavigationBar() {
        navigationController?.navigationBar.barTintColor = .groupTableViewBackground
        navigationController?.navigationBar.shadowImage = UIImage()
    }

    private func setupSearchBar() {
        navigationItem.titleView = searchBar
        searchBar.placeholder = constants.searchBarPlaceholder
    }

    private func setupCollectionView() {
        collectionView.registerCell(RecipeCollectionViewCell.self)
        collectionView.addSubview(refreshControl)
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumLineSpacing = constants.spacing
            layout.minimumInteritemSpacing = constants.spacing
            layout.sectionInset = constants.margins
        }
    }

    private func setupBindings() {

        // Bind searchbar to viewmodel's search text input
        searchBar.rx.text.orEmpty
            .debounce(0.2, scheduler: MainScheduler.instance)
            .bind(to: viewModel.setSearchText)
            .disposed(by: disposeBag)

        // Recipes bidings
        viewModel.getRecipes
            .bind(to: collectionView.rx.items(
                cellIdentifier: RecipeCollectionViewCell.identifier,
                cellType: RecipeCollectionViewCell.self)
            ) { (item, model, cell) in
                cell.render(model: model)
            }
            .disposed(by: disposeBag)

        viewModel.getRecipes
            .subscribe(onNext: { [weak self] (recipes) in
                self?.refreshControl.endRefreshing()
            })
            .disposed(by: disposeBag)

        // Bind item selection action
        collectionView.rx
            .modelSelected(RecipeCellViewModel.self)
            .asObservable()
            .map { $0.id }
            .bind(to: viewModel.setSelectRecipeId)
            .disposed(by: disposeBag)

        // Bind difficulty button title
        viewModel.getDifficulty
            .bind(to: difficultyButton.rx.title(for: .normal))
            .disposed(by: disposeBag)

        // Bind duration button tap
        difficultyButton.rx.tap.asObservable()
            .flatMap { [unowned self] in
                self.presentOptions(
                    title: "Select difficulty".localized(comment: "Difficulty selector's title"),
                    options: self.viewModel.difficulties
                )
            }
            .bind(to: viewModel.setDifficulty)
            .disposed(by: disposeBag)

        // Bind duration button title
        viewModel.getDuration
            .bind(to: durationButton.rx.title(for: .normal))
            .disposed(by: disposeBag)

        // Bind duration button tap 
        durationButton.rx.tap.asObservable()
            .flatMap { [unowned self] in
                self.presentOptions(
                    title: "Select duration".localized(comment: "Duration selector's title"),
                    options: self.viewModel.durations
                )
            }
            .bind(to: viewModel.setDuration)
            .disposed(by: disposeBag)

        // Bind Error presenter
        viewModel.getError
            .subscribe(onNext: { [weak self] (error) in
                guard let `self` = self,
                    let error = error
                    else { return }
                self.displayError(error)
            })
            .disposed(by: disposeBag)

        // Bind loading indicator
        viewModel.isLoading
            .subscribe(onNext: { (loading) in
                UIApplication.shared.isNetworkActivityIndicatorVisible = loading
            })
            .disposed(by: disposeBag)

        // Empty screen handling
        viewModel.displayEmptyScreen
            .subscribe(onNext: { [weak self] display in
                self?.emptyIndicatorView.isHidden = !display
            })
            .disposed(by: disposeBag)

        // Refresh
        refreshControl.rx.controlEvent(.valueChanged)
            .asObservable()
            .bind(to: viewModel.setRefresh)
            .disposed(by: disposeBag)
    }
}

// MARK: -

extension RecipesListViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - constants.spacing - constants.margins.sumHorizontal)/2
        let height = width / constants.aspectRatio
        return CGSize(width: width, height: height)
    }
}
