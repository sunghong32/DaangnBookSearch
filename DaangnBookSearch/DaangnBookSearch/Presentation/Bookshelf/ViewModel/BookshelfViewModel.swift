//
//  BookshelfViewModel.swift
//  DaangnBookSearch
//
//  Created by Assistant on 11/02/25.
//

import Foundation
import Combine

/// 내 책장 화면 ViewModel
///
/// MVI 패턴 기반으로 즐겨찾기 목록 표시와 관리 담당
/// BookshelfStore Publisher 구독으로 즐겨찾기 상태 자동 반영
@MainActor
final class BookshelfViewModel {

    struct State {
        var books: [BookSummary] = []
    }

    enum Intent {
        case load
        case remove(BookSummary)
    }

    private let bookshelfStore: BookshelfStore
    private let toggleBookshelfUseCase: ToggleBookshelfUseCase
    private(set) var state = State()
    private var stateChangeHandler: ((State) -> Void)?
    
    /// Combine 구독 보관용 Set
    /// 
    /// deinit 시 자동 해제되도록 보관
    private var cancellables = Set<AnyCancellable>()

    /// 초기화
    /// 
    /// - Parameters:
    ///   - bookshelfStore: 즐겨찾기 데이터를 관리하는 Store
    ///   - toggleBookshelfUseCase: 즐겨찾기 토글을 수행하는 UseCase
    /// 
    /// Store Publisher 구독으로 즐겨찾기 상태 자동 반영
    init(
        bookshelfStore: BookshelfStore,
        toggleBookshelfUseCase: ToggleBookshelfUseCase
    ) {
        self.bookshelfStore = bookshelfStore
        self.toggleBookshelfUseCase = toggleBookshelfUseCase
        
        // 즐겨찾기 Store의 Publisher 구독 시작
        setupFavoritesSubscription()
    }
    
    /// 즐겨찾기 Store Publisher 구독으로 상태 자동 갱신
    /// 
    /// Store 즐겨찾기 목록이 바뀌면 books 즉시 동기화
    /// 다른 화면에서 즐겨찾기를 바꿔도 여기서 자동 반영
    private func setupFavoritesSubscription() {
        Task {
            // actor에서 Publisher 가져오기 (비동기)
            let publisher = await bookshelfStore.booksPublisher
            
            // Publisher 구독하여 즐겨찾기 목록 업데이트
            publisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] books in
                    guard let self else { return }
                    self.mutateState { state in
                        state.books = books
                    }
                }
                .store(in: &cancellables)
        }
    }

    func setStateChangeHandler(_ handler: @escaping (State) -> Void) {
        stateChangeHandler = handler
    }

    /// Intent를 처리해 상태 변경 수행
    /// 
    /// - Parameter intent: 처리할 Intent
    /// 
    /// MVI에서 사용자 액션을 Intent로 받아 처리
    func send(_ intent: Intent) {
        switch intent {
        case .load:
            // Store Publisher가 상태를 자동 갱신하므로
            // 명시적인 로드는 생략
            // 필요 시 초기 상태만 동기화
            Task {
                let currentBooks = await bookshelfStore.currentBooks
                mutateState { state in
                    state.books = currentBooks
                }
            }

        case let .remove(book):
            Task { @MainActor [weak self] in
                guard let self else { return }
                
                // 이미 즐겨찾기에 있는 경우에만 제거 (UseCase 활용)
                do {
                    let currentBooks = await self.bookshelfStore.currentBooks
                    if currentBooks.contains(where: { $0.isbn13 == book.isbn13 }) {
                        // UseCase로 제거 (토글 사용)
                        try await self.toggleBookshelfUseCase.execute(book: book)
                        
                        // Store Publisher가 자동으로 상태를 갱신하므로
                        // 여기서는 상태 변경을 따로 수행하지 않음
                    }
                } catch {
                    // 에러 처리 (필요 시)
                    // Publisher 구독이 자동으로 상태를 갱신하므로
                    // 에러 발생 시에도 상태 유지
                }
            }
        }
    }

    private func mutateState(_ mutation: (inout State) -> Void) {
        mutation(&state)
        stateChangeHandler?(state)
    }
}


