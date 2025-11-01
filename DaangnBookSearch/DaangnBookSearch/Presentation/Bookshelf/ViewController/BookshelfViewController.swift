//
//  BookshelfViewController.swift
//  DaangnBookSearch
//
//  Created by Assistant on 11/1/25.
//

import UIKit

final class BookshelfViewController: UIViewController {

    private let viewModel: BookshelfViewModel
    private let detailViewControllerBuilder: (BookSummary) -> UIViewController
    private var currentState = BookshelfViewModel.State()

    private var customView: BookshelfView {
        view as! BookshelfView
    }

    init(
        viewModel: BookshelfViewModel,
        detailViewControllerBuilder: @escaping (BookSummary) -> UIViewController
    ) {
        self.viewModel = viewModel
        self.detailViewControllerBuilder = detailViewControllerBuilder
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = BookshelfView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureCollectionView()
        bindViewModel()
        viewModel.send(.load)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    private func configureCollectionView() {
        customView.collectionView.delegate = self
        customView.collectionView.dataSource = self
        customView.collectionView.register(
            BookshelfBookCell.self,
            forCellWithReuseIdentifier: BookshelfBookCell.identifier
        )
    }

    private func bindViewModel() {
        viewModel.setStateChangeHandler { [weak self] state in
            guard let self else { return }
            DispatchQueue.main.async {
                self.currentState = state
                self.customView.collectionView.reloadData()
                self.customView.updateBookCount(state.books.count)
                self.customView.setEmptyStateVisible(state.books.isEmpty)
            }
        }
    }
}

// MARK: - UICollectionViewDataSource

extension BookshelfViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        currentState.books.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: BookshelfBookCell.identifier,
            for: indexPath
        ) as! BookshelfBookCell
        let book = currentState.books[indexPath.item]
        cell.configure(with: book)
        cell.onFavoriteTap = { [weak self] in
            self?.viewModel.send(.remove(book))
        }
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension BookshelfViewController: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        let book = currentState.books[indexPath.item]
        let detailController = detailViewControllerBuilder(book)
        detailController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(detailController, animated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension BookshelfViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let totalWidth = collectionView.bounds.width
        let spacing: CGFloat = 16
        let itemWidth = (totalWidth - spacing) / 2
        return CGSize(width: floor(itemWidth), height: 230)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        16
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        16
    }
}

