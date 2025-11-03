//
//  BookshelfViewModel.swift
//  DaangnBookSearch
//
//  Created by Assistant on 11/02/25.
//

import Foundation
import Combine

/// 내 책장 화면의 ViewModel
///
/// MVI 패턴을 따르며, 즐겨찾기 목록을 표시하고 관리합니다.
/// BookshelfStore의 Publisher를 구독하여 즐겨찾기 상태 변화를 자동으로 반영합니다.
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
    
    /// Combine의 구독을 관리하는 Set
    /// 
    /// deinit 시 자동으로 구독이 취소되도록 저장합니다
    private var cancellables = Set<AnyCancellable>()

    /// 초기화
    /// 
    /// - Parameters:
    ///   - bookshelfStore: 즐겨찾기 데이터를 관리하는 Store
    ///   - toggleBookshelfUseCase: 즐겨찾기 토글을 수행하는 UseCase
    /// 
    /// Store의 Publisher를 구독하여 즐겨찾기 상태 변화를 자동으로 반영합니다.
    init(
        bookshelfStore: BookshelfStore,
        toggleBookshelfUseCase: ToggleBookshelfUseCase
    ) {
        self.bookshelfStore = bookshelfStore
        self.toggleBookshelfUseCase = toggleBookshelfUseCase
        
        // 즐겨찾기 Store의 Publisher 구독 시작
        setupFavoritesSubscription()
    }
    
    /// 즐겨찾기 Store의 Publisher를 구독하여 상태를 자동으로 업데이트합니다
    /// 
    /// Store의 즐겨찾기 목록이 변경되면 자동으로 books를 업데이트합니다.
    /// 이렇게 하면 다른 화면에서 즐겨찾기를 변경해도 이 화면이 자동으로 반영됩니다.
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

    /// Intent를 처리하여 상태를 변경합니다
    /// 
    /// - Parameter intent: 처리할 Intent
    /// 
    /// MVI 패턴에서 사용자가 발생시킨 액션을 Intent로 받아서 처리합니다.
    func send(_ intent: Intent) {
        switch intent {
        case .load:
            // Store의 Publisher가 자동으로 상태를 업데이트하므로
            // 명시적인 로드가 필요 없습니다
            // 필요시 초기 상태만 설정할 수 있습니다
            Task {
                let currentBooks = await bookshelfStore.currentBooks
                mutateState { state in
                    state.books = currentBooks
                }
            }

        case let .remove(book):
            Task { @MainActor [weak self] in
                guard let self else { return }
                
                // 이미 즐겨찾기에 있는 경우에만 제거 (UseCase를 통해)
                do {
                    let currentBooks = await self.bookshelfStore.currentBooks
                    if currentBooks.contains(where: { $0.isbn13 == book.isbn13 }) {
                        // UseCase를 통해 제거 (토글 사용)
                        _ = try await self.toggleBookshelfUseCase(book: book)
                        
                        // Store의 Publisher가 자동으로 상태를 업데이트하므로
                        // 여기서는 별도로 상태 변경이 필요 없습니다
                    }
                } catch {
                    // 에러 처리 (필요한 경우)
                    // Publisher 구독이 자동으로 상태를 업데이트하므로
                    // 에러가 발생해도 상태는 유지됩니다
                }
            }
        }
    }

    @MainActor
    private func mutateState(_ mutation: (inout State) -> Void) {
        mutation(&state)
        stateChangeHandler?(state)
    }
}


