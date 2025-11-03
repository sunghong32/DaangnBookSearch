//
//  SearchViewModel.swift
//  DaangnBookSearch
//
//  Created by 민성홍 on 10/31/25.
//

import Foundation
import Combine

/// 검색 화면의 ViewModel
///
/// MVI 패턴을 따르며, 검색 기능과 즐겨찾기 기능을 제공합니다.
/// BookshelfStore의 Publisher를 구독하여 즐겨찾기 상태 변화를 자동으로 반영합니다.
@MainActor
final class SearchViewModel {

    struct State {
        var query: String = ""
        var isLoading: Bool = false
        var isLoadingMore: Bool = false
        var books: [BookSummary] = []
        var page: Int = 1
        var total: Int = 0
        var errorMessage: String?
        var favoriteISBNs: Set<String> = []
    }

    enum Intent {
        case updateQuery(String)
        case search
        case loadMore
        case toggleFavorite(BookSummary)
    }

    private let searchBooksUseCase: SearchBooksUseCase
    private let toggleBookshelfUseCase: ToggleBookshelfUseCase
    private let bookshelfStore: BookshelfStore
    private(set) var state = State()
    private var stateChangeHandler: ((State) -> Void)?
    
    /// Combine의 구독을 관리하는 Set
    /// 
    /// deinit 시 자동으로 구독이 취소되도록 저장합니다
    private var cancellables = Set<AnyCancellable>()

    /// 초기화
    /// 
    /// - Parameters:
    ///   - searchBooksUseCase: 책 검색을 수행하는 UseCase
    ///   - toggleBookshelfUseCase: 즐겨찾기 토글을 수행하는 UseCase
    ///   - bookshelfStore: 즐겨찾기 데이터를 관리하는 Store
    /// 
    /// Store의 Publisher를 구독하여 즐겨찾기 상태 변화를 자동으로 반영합니다.
    init(
        searchBooksUseCase: SearchBooksUseCase,
        toggleBookshelfUseCase: ToggleBookshelfUseCase,
        bookshelfStore: BookshelfStore
    ) {
        self.searchBooksUseCase = searchBooksUseCase
        self.toggleBookshelfUseCase = toggleBookshelfUseCase
        self.bookshelfStore = bookshelfStore
        
        // 즐겨찾기 Store의 Publisher 구독 시작
        setupFavoritesSubscription()
    }
    
    /// 즐겨찾기 Store의 Publisher를 구독하여 상태를 자동으로 업데이트합니다
    /// 
    /// Store의 즐겨찾기 목록이 변경되면 자동으로 favoriteISBNs를 업데이트합니다.
    /// 이렇게 하면 다른 화면에서 즐겨찾기를 변경해도 이 화면이 자동으로 반영됩니다.
    private func setupFavoritesSubscription() {
        Task {
            // actor에서 Publisher 가져오기 (비동기)
            let publisher = await bookshelfStore.booksPublisher
            
            // Publisher 구독하여 즐겨찾기 ISBN Set 업데이트
            publisher
                .map { Set($0.map { $0.isbn13 }) }
                .receive(on: DispatchQueue.main)
                .sink { [weak self] favoriteISBNs in
                    guard let self else { return }
                    self.mutateState { state in
                        state.favoriteISBNs = favoriteISBNs
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
        case let .updateQuery(query):
            mutateState { state in
                state.query = query
            }

        case .search:
            Task {
                await performSearch()
            }

        case .loadMore:
            guard !state.isLoadingMore, state.books.count < state.total else { return }
            Task {
                await performLoadMore()
            }

        case let .toggleFavorite(book):
            Task { @MainActor [weak self] in
                guard let self else { return }
                
                do {
                    // UseCase를 통해 즐겨찾기 토글 수행
                    _ = try await self.toggleBookshelfUseCase(book: book)
                    
                    // Store의 Publisher가 자동으로 상태를 업데이트하므로
                    // 여기서는 별도로 상태 변경이 필요 없습니다
                } catch {
                    // 에러 처리 (필요한 경우)
                    self.mutateState { state in
                        state.errorMessage = "즐겨찾기 저장에 실패했습니다."
                    }
                }
            }
        }
    }

    /// 검색을 수행합니다
    /// 
    /// 쿼리가 비어있으면 검색하지 않습니다.
    /// 검색 결과를 받으면 상태를 업데이트합니다.
    /// 즐겨찾기 상태는 Publisher 구독을 통해 자동으로 업데이트됩니다.
    @MainActor
    private func performSearch() async {
        let query = state.query
        guard !query.isEmpty else { return }

        mutateState {
            $0.isLoading = true
            $0.isLoadingMore = false
            $0.errorMessage = nil
        }
        
        do {
            let result = try await searchBooksUseCase(query: query, page: 1)
            mutateState { state in
                state.books = result.items
                state.page = result.page
                state.total = result.total
                state.errorMessage = nil
                state.isLoading = false
                state.isLoadingMore = false
                // favoriteISBNs는 Publisher 구독을 통해 자동으로 업데이트됨
            }
        } catch {
            mutateState { state in
                state.errorMessage = "검색 결과를 불러오지 못했습니다."
                state.isLoading = false
                state.isLoadingMore = false
            }
        }
    }

    /// 추가 검색 결과를 불러옵니다 (페이징)
    /// 
    /// 현재 페이지의 다음 페이지를 불러와서 기존 결과에 추가합니다.
    /// 더 이상 불러올 데이터가 없으면 호출되지 않습니다.
    @MainActor
    private func performLoadMore() async {
        let query = state.query
        let nextPage = state.page + 1

        mutateState {
            $0.isLoading = true
            $0.isLoadingMore = true
        }
        
        do {
            let result = try await searchBooksUseCase(query: query, page: nextPage)
            mutateState { state in
                state.books += result.items
                state.page = result.page
                state.total = result.total
                state.isLoading = false
                state.isLoadingMore = false
                // favoriteISBNs는 Publisher 구독을 통해 자동으로 업데이트됨
            }
        } catch {
            mutateState { state in
                state.errorMessage = "검색 결과를 불러오지 못했습니다."
                state.isLoading = false
                state.isLoadingMore = false
            }
        }
    }

    @MainActor
    private func mutateState(_ mutation: (inout State) -> Void) {
        mutation(&state)
        notifyStateChange()
    }

    private func notifyStateChange() {
        stateChangeHandler?(state)
    }

}
