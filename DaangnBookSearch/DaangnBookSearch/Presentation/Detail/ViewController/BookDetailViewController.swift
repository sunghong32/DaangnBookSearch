//
//  BookDetailViewController.swift
//  DaangnBookSearch
//
//  Moved & updated by Assistant on 10/31/25.
//

import Foundation
import UIKit

final class BookDetailViewController: UIViewController {

    private let viewModel: BookDetailViewModel
    private let initialSummary: BookSummary?
    private let bookshelfStore: BookshelfStore
    private var currentDetail: BookDetail?
    private var isFavorite = false
    private var lastErrorMessage: String?
    private var bookshelfObserver: NSObjectProtocol?

    private var detailView: BookDetailView { view as! BookDetailView }

    init(viewModel: BookDetailViewModel, summary: BookSummary? = nil, bookshelfStore: BookshelfStore) {
        self.viewModel = viewModel
        self.initialSummary = summary
        self.bookshelfStore = bookshelfStore
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        if let observer = bookshelfObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    override func loadView() {
        view = BookDetailView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .systemBackground
        setupBindings()
        if let summary = initialSummary {
            preconfigure(with: summary)
        }
        render(state: viewModel.state)
        viewModel.send(.load)
        syncFavoriteStateWithStore()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    private func setupBindings() {
        detailView.onAddToShelfTap = { [weak self] in
            self?.toggleFavoriteState()
        }

        detailView.onPDFSelected = { [weak self] url in
            self?.presentPDF(url)
        }

        detailView.onBackButtonTap = { [weak self] in
            self?.handleBackButtonTapped()
        }

        bookshelfObserver = NotificationCenter.default.addObserver(
            forName: .bookshelfDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.syncFavoriteStateWithStore()
        }

        viewModel.setStateChangeHandler { [weak self] state in
            DispatchQueue.main.async {
                self?.render(state: state)
            }
        }
    }

    private func render(state: BookDetailViewModel.State) {
        detailView.setLoading(state.isLoading)

        if let detail = state.detail {
            currentDetail = detail
            isFavorite = bookshelfStore.contains(isbn13: detail.isbn13)
            detailView.configure(with: makeViewData(detail: detail))
            detailView.updateFavoriteState(isFavorite: isFavorite)
        }

        if let message = state.errorMessage, message != lastErrorMessage {
            lastErrorMessage = message
            presentErrorAlert(message: message)
        }
    }

    private func toggleFavoriteState() {
        guard let summary = currentSummary() else { return }
        let isNowFavorite = bookshelfStore.toggle(summary)
        isFavorite = isNowFavorite
        detailView.updateFavoriteState(isFavorite: isFavorite)
    }

    private func makeViewData(detail: BookDetail) -> BookDetailView.ViewData {
        let description = detail.desc.isEmpty ? "상세 설명이 없습니다." : detail.desc
        let pdfItems: [BookDetailView.ViewData.PDFItem] = detail.pdfs
            .sorted { $0.key < $1.key }
            .compactMap { key, value in
                BookDetailView.ViewData.PDFItem(title: key, url: value)
            }

        let pages = detail.pages.isEmpty ? "" : "\(detail.pages)쪽"
        return BookDetailView.ViewData(
            title: detail.title,
            subtitle: detail.subtitle,
            price: detail.price,
            authors: detail.authors,
            publisher: detail.publisher,
            pages: pages,
            year: detail.year,
            description: description,
            imageURL: detail.imageURL,
            pdfs: pdfItems,
            isFavorited: isFavorite
        )
    }

    private func preconfigure(with summary: BookSummary) {
        navigationItem.title = summary.title
        let provisionalData = BookDetailView.ViewData(
            title: summary.title,
            subtitle: summary.subtitle,
            price: summary.price,
            authors: "",
            publisher: "",
            pages: "",
            year: "",
            description: "",
            imageURL: summary.imageURL,
            pdfs: [],
            isFavorited: bookshelfStore.contains(isbn13: summary.isbn13)
        )
        detailView.configure(with: provisionalData)
        isFavorite = bookshelfStore.contains(isbn13: summary.isbn13)
        detailView.updateFavoriteState(isFavorite: isFavorite)
    }

    private func presentPDF(_ url: URL) {
        let pdfViewController = PDFViewController(url: url, title: url.lastPathComponent)
        navigationController?.pushViewController(pdfViewController, animated: true)
    }

    private func presentErrorAlert(message: String) {
        let alert = UIAlertController(title: "오류", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }

    @objc
    private func handleBackButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    private func currentSummary() -> BookSummary? {
        if let detail = currentDetail {
            return BookSummary(
                title: detail.title,
                subtitle: detail.subtitle,
                isbn13: detail.isbn13,
                price: detail.price,
                imageURL: detail.imageURL,
                url: detail.url
            )
        }
        if let summary = initialSummary {
            return summary
        }
        return nil
    }

    private func syncFavoriteStateWithStore() {
        guard let isbn = currentSummary()?.isbn13 else { return }
        let exists = bookshelfStore.contains(isbn13: isbn)
        guard exists != isFavorite else { return }
        isFavorite = exists
        detailView.updateFavoriteState(isFavorite: exists)
    }
}
