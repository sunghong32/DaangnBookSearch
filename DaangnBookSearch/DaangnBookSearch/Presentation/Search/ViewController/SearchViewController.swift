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
    private var currentState = SearchViewModel.State()
    private var previousErrorMessage: String?
    private var hasPerformedSearch = false

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
        customView.collectionView.register(
            LoadingFooterView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: LoadingFooterView.identifier
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
                self.currentState = state
                self.customView.updateQueryText(state.query)
                let isInitialLoading = state.isLoading && !state.isLoadingMore
                self.customView.setLoadingOverlayVisible(isInitialLoading)
                self.renderPlaceholders(for: state)
                self.customView.collectionView.reloadData()
                self.handleErrorIfNeeded(message: state.errorMessage)
            }
        }
    }

    @objc
    private func handleTextFieldChange(_ textField: UITextField) {
        viewModel.send(.updateQuery(textField.text ?? ""))
        if (textField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            hasPerformedSearch = false
            renderPlaceholders(for: currentState)
        }
    }

    @objc
    private func handleSearchButtonTap() {
        hasPerformedSearch = true
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
        return CGSize(width: width, height: 155)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForFooterInSection section: Int
    ) -> CGSize {
        guard currentState.isLoadingMore else { return .zero }
        return CGSize(width: collectionView.bounds.width, height: 60)
    }
}

// MARK: - UICollectionViewDataSource

extension SearchViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        currentState.books.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: BookCell.identifier,
            for: indexPath
        ) as! BookCell
        cell.configure(with: currentState.books[indexPath.item])
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            let footer = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: LoadingFooterView.identifier,
                for: indexPath
            ) as! LoadingFooterView
            footer.setLoading(currentState.isLoadingMore)
            return footer
        }
        return UICollectionReusableView()
    }
}

// MARK: - UICollectionViewDelegate

extension SearchViewController: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        let book = currentState.books[indexPath.item]
        print("Selected: \(book.title)")
    }

    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        let threshold = currentState.books.count - 5
        if threshold >= 0, indexPath.item == threshold {
            viewModel.send(.loadMore)
        }
    }
}

// MARK: - UITextFieldDelegate

extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        hasPerformedSearch = true
        viewModel.send(.search)
        return true
    }
}

// MARK: - Private Helpers

private extension SearchViewController {
    func renderPlaceholders(for state: SearchViewModel.State) {
        if state.isLoadingMore {
            customView.hidePlaceholders()
            customView.setCollectionViewVisible(true)
            return
        }

        if state.isLoading {
            customView.hidePlaceholders()
            customView.setCollectionViewVisible(false)
            return
        }

        if hasPerformedSearch {
            if state.books.isEmpty {
                customView.showEmptyResultPlaceholder()
                customView.setCollectionViewVisible(false)
            } else {
                customView.hidePlaceholders()
                customView.setCollectionViewVisible(true)
            }
        } else {
            customView.showInitialPlaceholder()
            customView.setCollectionViewVisible(false)
        }
    }

    func handleErrorIfNeeded(message: String?) {
        guard let message else {
            previousErrorMessage = nil
            return
        }
        guard message != previousErrorMessage else { return }
        previousErrorMessage = message

        let alert = UIAlertController(title: "오류", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        if presentedViewController == nil {
            present(alert, animated: true)
        }
    }
}
