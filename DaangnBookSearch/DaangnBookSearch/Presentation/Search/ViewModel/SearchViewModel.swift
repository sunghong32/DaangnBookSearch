//
//  SearchViewModel.swift
//  DaangnBookSearch
//
//  Created by 민성홍 on 10/31/25.
//

import Foundation

final class SearchViewModel {

    struct State {
        var query: String = ""
        var isLoading: Bool = false
        var isLoadingMore: Bool = false
        var books: [BookSummary] = []
        var page: Int = 1
        var total: Int = 0
        var errorMessage: String?
    }

    enum Intent {
        case updateQuery(String)
        case search
        case loadMore
    }

    private let searchBooksUseCase: SearchBooksUseCase
    private(set) var state = State()
    private var stateChangeHandler: ((State) -> Void)?

    init(searchBooksUseCase: SearchBooksUseCase) {
        self.searchBooksUseCase = searchBooksUseCase
    }

    func setStateChangeHandler(_ handler: @escaping (State) -> Void) {
        stateChangeHandler = handler
    }

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
        }
    }

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
