//
//  BookDetailViewController.swift
//  DaangnBookSearch
//
//  Moved & updated by Assistant on 10/31/25.
//

import Foundation
import UIKit
import Combine

/// 책 상세 화면의 ViewController
///
/// BookshelfStore의 Publisher를 구독하여 즐겨찾기 상태 변화를 자동으로 반영합니다.
final class BookDetailViewController: UIViewController {

    private let viewModel: BookDetailViewModel
    private let initialSummary: BookSummary?
    private let bookshelfStore: BookshelfStore
    private let toggleBookshelfUseCase: ToggleBookshelfUseCase
    private var currentDetail: BookDetail?
    private var isFavorite = false
    private var lastErrorMessage: String?
    
    /// Combine의 구독을 관리하는 Set
    /// 
    /// deinit 시 자동으로 구독이 취소되도록 저장합니다
    private var cancellables = Set<AnyCancellable>()

    private var detailView: BookDetailView { view as! BookDetailView }

    /// 초기화
    /// 
    /// - Parameters:
    ///   - viewModel: 책 상세 정보를 관리하는 ViewModel
    ///   - summary: 초기 표시할 책 정보 (선택적)
    ///   - bookshelfStore: 즐겨찾기 데이터를 관리하는 Store
    ///   - toggleBookshelfUseCase: 즐겨찾기 토글을 수행하는 UseCase
    init(
        viewModel: BookDetailViewModel,
        summary: BookSummary? = nil,
        bookshelfStore: BookshelfStore,
        toggleBookshelfUseCase: ToggleBookshelfUseCase
    ) {
        self.viewModel = viewModel
        self.initialSummary = summary
        self.bookshelfStore = bookshelfStore
        self.toggleBookshelfUseCase = toggleBookshelfUseCase
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        syncFavoriteStateWithStore()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    /// View와 ViewModel 간 바인딩 설정
    /// 
    /// Store의 Publisher를 구독하여 즐겨찾기 상태 변화를 자동으로 반영합니다.
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

        viewModel.setStateChangeHandler { [weak self] state in
            DispatchQueue.main.async {
                self?.render(state: state)
            }
        }
        
        // BookshelfStore의 Publisher 구독 시작
        setupFavoritesSubscription()
    }
    
    /// 즐겨찾기 Store의 Publisher를 구독하여 상태를 자동으로 업데이트합니다
    /// 
    /// Store의 즐겨찾기 목록이 변경되면 현재 책의 즐겨찾기 상태를 자동으로 확인합니다.
    /// 이렇게 하면 다른 화면에서 즐겨찾기를 변경해도 이 화면이 자동으로 반영됩니다.
    private func setupFavoritesSubscription() {
        Task {
            // actor에서 Publisher 가져오기 (비동기)
            let publisher = await bookshelfStore.booksPublisher
            
            // Publisher 구독하여 즐겨찾기 상태 업데이트
            publisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] favorites in
                    guard let self else { return }
                    self.syncFavoriteStateWithStore()
                }
                .store(in: &cancellables)
        }
    }

    /// ViewModel의 상태를 UI에 반영합니다
    /// 
    /// - Parameter state: ViewModel의 현재 상태
    private func render(state: BookDetailViewModel.State) {
        detailView.setLoading(state.isLoading)

        if let detail = state.detail {
            currentDetail = detail
            // Store에서 현재 즐겨찾기 상태 확인 (비동기)
            Task {
                let favoriteISBNs = await bookshelfStore.favoriteISBNs
                isFavorite = favoriteISBNs.contains(detail.isbn13)
                await MainActor.run {
                    detailView.configure(with: makeViewData(detail: detail))
                    detailView.updateFavoriteState(isFavorite: isFavorite)
                }
            }
        }

        if let message = state.errorMessage, message != lastErrorMessage {
            lastErrorMessage = message
            presentErrorAlert(message: message)
        }
    }

    /// 즐겨찾기 상태를 토글합니다
    /// 
    /// UseCase를 통해 Store를 업데이트하며, Publisher가 자동으로 상태를 반영합니다.
    private func toggleFavoriteState() {
        guard let summary = currentSummary() else { return }
        
        Task {
            do {
                // UseCase를 통해 즐겨찾기 토글 수행
                let isNowFavorite = try await toggleBookshelfUseCase(book: summary)
                
                // UI 업데이트
                await MainActor.run {
                    isFavorite = isNowFavorite
                    detailView.updateFavoriteState(isFavorite: isFavorite)
                }
            } catch {
                // 에러 처리
                await MainActor.run {
                    presentErrorAlert(message: "즐겨찾기 저장에 실패했습니다.")
                }
            }
        }
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

    /// 초기 책 정보로 화면을 미리 구성합니다
    /// 
    /// - Parameter summary: 초기 표시할 책 정보
    /// 
    /// 상세 정보가 로드되기 전에 미리 책 정보를 표시합니다.
    private func preconfigure(with summary: BookSummary) {
        navigationItem.title = summary.title
        
        // Store에서 현재 즐겨찾기 상태 확인 (비동기)
        Task {
            let favoriteISBNs = await bookshelfStore.favoriteISBNs
            let isFavorited = favoriteISBNs.contains(summary.isbn13)
            
            await MainActor.run {
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
                    isFavorited: isFavorited
                )
                detailView.configure(with: provisionalData)
                isFavorite = isFavorited
                detailView.updateFavoriteState(isFavorite: isFavorite)
            }
        }
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

    /// Store의 즐겨찾기 상태와 UI 상태를 동기화합니다
    /// 
    /// Store의 Publisher가 변경을 감지하면 자동으로 호출됩니다.
    /// 현재 책의 즐겨찾기 상태를 확인하여 UI를 업데이트합니다.
    private func syncFavoriteStateWithStore() {
        guard let isbn = currentSummary()?.isbn13 else { return }
        
        Task {
            let favoriteISBNs = await bookshelfStore.favoriteISBNs
            let exists = favoriteISBNs.contains(isbn)
            
            guard exists != isFavorite else { return }
            
            await MainActor.run {
                isFavorite = exists
                detailView.updateFavoriteState(isFavorite: exists)
            }
        }
    }
}
