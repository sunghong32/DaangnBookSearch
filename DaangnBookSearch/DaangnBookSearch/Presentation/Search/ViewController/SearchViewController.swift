//
//  SearchViewController.swift
//  DaangnBookSearch
//
//  Moved & updated by Assistant on 10/31/25.
//

import UIKit

final class SearchViewController: UIViewController {

    private let viewModel: SearchViewModel
    private let detailViewControllerBuilder: (BookSummary) -> UIViewController
    private var customView: SearchView {
        view as! SearchView
    }
    private var currentState = SearchViewModel.State()
    private var previousErrorMessage: String?
    private var hasPerformedSearch = false
    private var histories: [String] = SearchHistoryStore.shared.loadHistories()

    init(viewModel: SearchViewModel, detailViewControllerBuilder: @escaping (BookSummary) -> UIViewController) {
        self.viewModel = viewModel
        self.detailViewControllerBuilder = detailViewControllerBuilder
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
        renderHistoryVisibility()
        customView.historyDropdownCollectionView.reloadData()
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

        customView.historyDropdownCollectionView.delegate = self
        customView.historyDropdownCollectionView.dataSource = self
        customView.historyDropdownCollectionView.register(
            SearchHistoryDropdownCell.self,
            forCellWithReuseIdentifier: SearchHistoryDropdownCell.identifier
        )
    }

    private func configureInputs() {
        customView.queryTextField.delegate = self
        customView.queryTextField.addTarget(self, action: #selector(handleTextFieldChange(_:)), for: .editingChanged)
        customView.searchButton.addTarget(self, action: #selector(handleSearchButtonTap), for: .touchUpInside)
        customView.historyClearButton.addTarget(self, action: #selector(handleHistoryClearTap), for: .touchUpInside)
        customView.queryTextField.addTarget(self, action: #selector(handleTextFieldEditingDidBegin(_:)), for: .editingDidBegin)
        customView.queryTextField.addTarget(self, action: #selector(handleTextFieldEditingDidEnd(_:)), for: .editingDidEnd)
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
                self.customView.historyDropdownCollectionView.reloadData()
                self.handleErrorIfNeeded(message: state.errorMessage)
            }
        }
    }

    @objc
    private func handleTextFieldChange(_ textField: UITextField) {
        viewModel.send(.updateQuery(textField.text ?? ""))
        renderPlaceholders(for: currentState)
        renderHistoryVisibility()
    }

    @objc
    private func handleSearchButtonTap() {
        hasPerformedSearch = true
        customView.queryTextField.resignFirstResponder()
        viewModel.send(.search)
        storeHistoryIfNeeded()
    }
    
    @objc
    private func handleHistoryClearTap() {
        SearchHistoryStore.shared.clear()
        histories = []
        renderHistoryVisibility()
        customView.historyDropdownCollectionView.reloadData()
    }

    @objc
    private func handleTextFieldEditingDidBegin(_ textField: UITextField) {
        renderHistoryVisibility()
    }

    @objc
    private func handleTextFieldEditingDidEnd(_ textField: UITextField) {
        customView.setHistoryDropdownVisible(false)
        customView.updateHistoryDropdownHeight(itemCount: 0)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension SearchViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        if collectionView === customView.historyDropdownCollectionView {
            let width = collectionView.bounds.width
            return CGSize(width: width, height: 51)
        }
        let width = collectionView.bounds.width - 32
        return CGSize(width: width, height: 155)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        if collectionView === customView.historyDropdownCollectionView {
            return 0
        }
        return 16
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForFooterInSection section: Int
    ) -> CGSize {
        guard collectionView === customView.collectionView else { return .zero }
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
        if collectionView === customView.historyDropdownCollectionView {
            return histories.count
        }
        return currentState.books.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        if collectionView === customView.historyDropdownCollectionView {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: SearchHistoryDropdownCell.identifier,
                for: indexPath
            ) as! SearchHistoryDropdownCell
            let text = histories[indexPath.item]
            cell.configure(with: text)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: BookCell.identifier,
                for: indexPath
            ) as! BookCell
            let book = currentState.books[indexPath.item]
            let isFavorite = currentState.favoriteISBNs.contains(book.isbn13)
            cell.configure(with: book, isFavorite: isFavorite)
            cell.onFavoriteTap = { [weak self] in
                self?.viewModel.send(.toggleFavorite(book))
            }
            return cell
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard collectionView === customView.collectionView else {
            return UICollectionReusableView()
        }
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
        if collectionView === customView.historyDropdownCollectionView {
            let history = histories[indexPath.item]
            customView.queryTextField.text = history
            hasPerformedSearch = true
            customView.queryTextField.resignFirstResponder()
            renderHistoryVisibility()
            viewModel.send(.updateQuery(history))
            viewModel.send(.search)
            storeHistoryIfNeeded()
        } else {
            let summary = currentState.books[indexPath.item]
            let detailViewController = detailViewControllerBuilder(summary)
            detailViewController.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(detailViewController, animated: true)
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard collectionView === customView.collectionView else { return }
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
        storeHistoryIfNeeded()
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

        renderHistoryVisibility()
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

    func renderHistoryVisibility() {
        let trimmed = (customView.queryTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let shouldShow = customView.queryTextField.isFirstResponder && trimmed.isEmpty && !histories.isEmpty
        customView.setHistoryDropdownVisible(shouldShow)
        let itemCount = shouldShow ? histories.count : 0
        customView.updateHistoryDropdownHeight(itemCount: itemCount)
        if shouldShow {
            customView.hidePlaceholders()
        }
        if shouldShow {
            customView.historyDropdownCollectionView.reloadData()
        }
        customView.historyClearButton.isHidden = histories.isEmpty
    }

    func storeHistoryIfNeeded() {
        let text = (customView.queryTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        SearchHistoryStore.shared.addHistory(text)
        histories = SearchHistoryStore.shared.loadHistories()
        renderHistoryVisibility()
        customView.historyDropdownCollectionView.reloadData()
    }
}
