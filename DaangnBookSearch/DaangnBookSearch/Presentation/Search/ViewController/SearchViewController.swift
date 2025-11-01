//
//  SearchViewController.swift
//  DaangnBookSearch
//
//  Moved & updated by Assistant on 10/31/25.
//

import UIKit

final class SearchViewController: UIViewController {

    private let viewModel: SearchViewModel
    private var customView: SearchView {
        view as! SearchView
    }

    init(viewModel: SearchViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = SearchView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "책 검색"
        configureCollectionView()
        configureInputs()
        observeViewModel()
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
            BookCell.self,
            forCellWithReuseIdentifier: BookCell.identifier
        )
    }

    private func configureInputs() {
        customView.queryTextField.delegate = self
        customView.queryTextField.addTarget(self, action: #selector(handleTextFieldChange(_:)), for: .editingChanged)
        customView.searchButton.addTarget(self, action: #selector(handleSearchButtonTap), for: .touchUpInside)
    }

    private func observeViewModel() {
        viewModel.setStateChangeHandler { [weak self] state in
            guard let self else { return }
            DispatchQueue.main.async {
                let shouldHideEmpty = !state.books.isEmpty || state.isLoading
                self.customView.updateEmptyState(isHidden: shouldHideEmpty)
                self.customView.collectionView.reloadData()
            }
        }
    }

    @objc
    private func handleTextFieldChange(_ textField: UITextField) {
        viewModel.send(.updateQuery(textField.text ?? ""))
    }

    @objc
    private func handleSearchButtonTap() {
        customView.queryTextField.resignFirstResponder()
        viewModel.send(.search)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension SearchViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = collectionView.bounds.width - 32
        return CGSize(width: width, height: 120)
    }
}

// MARK: - UICollectionViewDataSource

extension SearchViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        viewModel.state.books.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: BookCell.identifier,
            for: indexPath
        ) as! BookCell
        cell.configure(with: viewModel.state.books[indexPath.item])
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension SearchViewController: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        let book = viewModel.state.books[indexPath.item]
        print("Selected: \(book.title)")
    }

    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        let threshold = viewModel.state.books.count - 5
        if indexPath.item == threshold {
            viewModel.send(.loadMore)
        }
    }
}

// MARK: - UITextFieldDelegate

extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        viewModel.send(.search)
        return true
    }
}
