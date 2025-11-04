//
//  BookDetailViewController.swift
//  DaangnBookSearch
//
//  Moved & updated by Assistant on 10/31/25.
//

import Foundation
import UIKit
import Combine

/// 책 상세 화면 ViewController
///
/// BookshelfStore Publisher 구독으로 즐겨찾기 상태 자동 반영
final class BookDetailViewController: UIViewController {

    private let viewModel: BookDetailViewModel
    private let initialSummary: BookSummary?
    private let bookshelfStore: BookshelfStore
    private let toggleBookshelfUseCase: ToggleBookshelfUseCase
    private var currentDetail: BookDetail?
    private var isFavorite = false
    private var lastErrorMessage: String?
    
    /// Combine 구독 보관용 Set
    /// 
    /// deinit 시 자동 해제되도록 보관
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
    /// Store Publisher 구독으로 즐겨찾기 상태 자동 반영
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
    
    /// 즐겨찾기 Store Publisher 구독으로 상태 자동 갱신
    /// 
    /// Store 즐겨찾기 목록이 바뀌면 현재 책 즐겨찾기 상태를 즉시 확인
    /// 다른 화면에서 즐겨찾기를 바꿔도 여기서 자동 반영
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

    /// ViewModel 상태를 UI에 반영
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

    /// 즐겨찾기 상태 토글
    /// 
    /// UseCase로 Store 갱신, Publisher가 자동 상태 반영
    private func toggleFavoriteState() {
        guard let summary = currentSummary() else { return }
        
        Task {
            do {
                // UseCase를 통해 즐겨찾기 토글 수행
                let isNowFavorite = try await toggleBookshelfUseCase.execute(book: summary)
                
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

    /// 초기 책 정보로 화면 사전 구성
    /// 
    /// - Parameter summary: 초기 표시할 책 정보
    /// 
    /// 상세 정보 로드 전 기본 정보 표시
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

    /// Store 즐겨찾기 상태와 UI 상태 동기화
    /// 
    /// Store Publisher 변경 감지 시 자동 호출
    /// 현재 책 즐겨찾기 상태를 확인해 UI 갱신
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
