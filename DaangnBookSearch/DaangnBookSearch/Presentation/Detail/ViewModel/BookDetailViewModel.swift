//
//  BookDetailViewModel.swift
//  DaangnBookSearch
//
//  Created by 민성홍 on 10/31/25.
//

import Foundation

final class BookDetailViewModel {

    struct State {
        var isbn13: String = ""
        var isLoading: Bool = false
        var detail: BookDetail?
        var errorMessage: String?
    }

    enum Intent {
        case setISBN(String)
        case load
    }

    private let fetchBookDetailUseCase: FetchBookDetailUseCase
    private(set) var state = State()

    init(fetchBookDetailUseCase: FetchBookDetailUseCase) {
        self.fetchBookDetailUseCase = fetchBookDetailUseCase
    }

    func send(_ intent: Intent) {
        switch intent {
        case let .setISBN(isbn13):
            state.isbn13 = isbn13

        case .load:
            guard state.isbn13.isEmpty == false else { return }
            Task {
                await loadDetail(isbn13: state.isbn13)
            }
        }
    }

    @MainActor
    private func loadDetail(isbn13: String) async {
        state.isLoading = true
        do {
            let detail = try await fetchBookDetailUseCase(isbn13: isbn13)
            state.detail = detail
            state.errorMessage = nil
        } catch {
            state.errorMessage = "상세 정보를 불러오지 못했습니다."
        }
        state.isLoading = false
    }
}
