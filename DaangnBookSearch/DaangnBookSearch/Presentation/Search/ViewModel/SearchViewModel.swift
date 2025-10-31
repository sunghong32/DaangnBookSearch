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

    init(searchBooksUseCase: SearchBooksUseCase) {
        self.searchBooksUseCase = searchBooksUseCase
    }

    func send(_ intent: Intent) {
        switch intent {
        case let .updateQuery(query):
            state.query = query

        case .search:
            Task {
                await fetchBooks(query: state.query, page: 1)
            }

        case .loadMore:
            guard !state.isLoading, state.books.count < state.total else { return }
            Task {
                await fetchBooks(query: state.query, page: state.page + 1)
            }
        }
    }

    @MainActor
    private func fetchBooks(query: String, page: Int) async {
        state.isLoading = true
        do {
            let result = try await searchBooksUseCase(query: query, page: page)
            if page == 1 {
                state.books = result.items
            } else {
                state.books += result.items
            }
            state.page = result.page
            state.total = result.total
            state.errorMessage = nil
        } catch {
            state.errorMessage = "검색 결과를 불러오지 못했습니다."
        }
        state.isLoading = false
    }
}
