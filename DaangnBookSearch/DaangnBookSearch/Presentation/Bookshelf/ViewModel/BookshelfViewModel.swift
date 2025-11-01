//
//  BookshelfViewModel.swift
//  DaangnBookSearch
//
//  Created by Assistant on 11/02/25.
//

import Foundation

final class BookshelfViewModel {

    struct State {
        var books: [BookSummary] = []
    }

    enum Intent {
        case load
        case remove(BookSummary)
    }

    private let bookshelfStore: BookshelfStore
    private(set) var state = State()
    private var stateChangeHandler: ((State) -> Void)?
    private var bookshelfObserver: NSObjectProtocol?

    deinit {
        if let observer = bookshelfObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    init(bookshelfStore: BookshelfStore) {
        self.bookshelfStore = bookshelfStore
        state.books = bookshelfStore.currentBooks
        bookshelfObserver = NotificationCenter.default.addObserver(
            forName: .bookshelfDidChange,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self else { return }
            let books = (notification.userInfo?["books"] as? [BookSummary]) ?? self.bookshelfStore.currentBooks
            self.mutateState { state in
                state.books = books
            }
        }
    }

    func setStateChangeHandler(_ handler: @escaping (State) -> Void) {
        stateChangeHandler = handler
    }

    func send(_ intent: Intent) {
        switch intent {
        case .load:
            mutateState { state in
                state.books = bookshelfStore.currentBooks
            }

        case let .remove(book):
            bookshelfStore.remove(isbn13: book.isbn13)
        }
    }

    @MainActor
    private func mutateState(_ mutation: (inout State) -> Void) {
        mutation(&state)
        stateChangeHandler?(state)
    }
}


