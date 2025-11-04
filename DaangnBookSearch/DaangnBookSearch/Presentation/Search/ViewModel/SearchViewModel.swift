//
//  SearchViewModel.swift
//  DaangnBookSearch
//
//  Created by 민성홍 on 10/31/25.
//

import Foundation
import Combine

/// 검색 화면 ViewModel
///
/// MVI 패턴 기반으로 검색과 즐겨찾기 흐름 담당
/// BookshelfStore Publisher 구독으로 즐겨찾기 상태 자동 반영
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
    
    /// Combine 구독 보관용 Set
    /// 
    /// deinit 시 자동 해제되도록 보관
    private var cancellables = Set<AnyCancellable>()

    /// 초기화
    /// 
    /// - Parameters:
    ///   - searchBooksUseCase: 책 검색을 수행하는 UseCase
    ///   - toggleBookshelfUseCase: 즐겨찾기 토글을 수행하는 UseCase
    ///   - bookshelfStore: 즐겨찾기 데이터를 관리하는 Store
    /// 
    /// Store Publisher 구독으로 즐겨찾기 상태 자동 반영
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
    
    /// 즐겨찾기 Store Publisher 구독으로 상태 자동 갱신
    /// 
    /// Store 즐겨찾기 목록이 바뀌면 favoriteISBNs 즉시 동기화
    /// 다른 화면에서 즐겨찾기를 바꿔도 여기서 자동 반영
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

    /// Intent를 처리해 상태 변경 수행
    /// 
    /// - Parameter intent: 처리할 Intent
    /// 
    /// MVI에서 사용자 액션을 Intent로 받아 처리
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
                    try await self.toggleBookshelfUseCase.execute(book: book)
                    
                    // Store Publisher가 자동으로 상태를 갱신하므로
                    // 여기서는 상태 변경을 따로 수행하지 않음
                } catch {
                    // 에러 처리 (필요한 경우)
                    self.mutateState { state in
                        state.errorMessage = "즐겨찾기 저장에 실패했습니다."
                    }
                }
            }
        }
    }

    /// 검색 실행
    /// 
    /// 쿼리가 비어있으면 즉시 반환
    /// 결과를 수신하면 상태 갱신
    /// 즐겨찾기 상태는 Publisher 구독으로 자동 갱신
    private func performSearch() async {
        let query = state.query
        guard !query.isEmpty else { return }

        mutateState {
            $0.isLoading = true
            $0.isLoadingMore = false
            $0.errorMessage = nil
        }
        
        do {
            let result = try await searchBooksUseCase.execute(query: query, page: 1)
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

    /// 추가 검색 결과 로드 (페이징)
    /// 
    /// 현재 페이지 다음 데이터를 불러와 기존 결과에 이어 붙임
    /// 더 가져올 데이터가 없으면 호출하지 않음
    private func performLoadMore() async {
        let query = state.query
        let nextPage = state.page + 1

        mutateState {
            $0.isLoading = true
            $0.isLoadingMore = true
        }
        
        do {
            let result = try await searchBooksUseCase.execute(query: query, page: nextPage)
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

    private func mutateState(_ mutation: (inout State) -> Void) {
        mutation(&state)
        notifyStateChange()
    }

    private func notifyStateChange() {
        stateChangeHandler?(state)
    }

}
