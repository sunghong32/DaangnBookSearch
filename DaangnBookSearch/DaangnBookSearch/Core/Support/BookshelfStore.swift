//
//  BookshelfStore.swift
//  DaangnBookSearch
//
//  Created by Assistant on 11/02/25.
//

import Foundation

extension Notification.Name {
    static let bookshelfDidChange = Notification.Name("BookshelfStore.bookshelfDidChange")
}

final class BookshelfStore {

    static let shared = BookshelfStore()

    private let userDefaults: UserDefaults
    private let storageKey = "bookshelf.items"

    private(set) var currentBooks: [BookSummary] {
        didSet {
            persist()
            notifyChange()
        }
    }

    // MARK: - Init

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        if
            let data = userDefaults.data(forKey: storageKey),
            let decoded = try? JSONDecoder().decode([BookSummary].self, from: data)
        {
            currentBooks = decoded
        } else {
            currentBooks = []
        }
    }

    // MARK: - Public API

    func contains(isbn13: String) -> Bool {
        currentBooks.contains { $0.isbn13 == isbn13 }
    }

    @discardableResult
    func add(_ book: BookSummary) -> Bool {
        guard contains(isbn13: book.isbn13) == false else { return false }
        currentBooks.insert(book, at: 0)
        return true
    }

    @discardableResult
    func remove(isbn13: String) -> Bool {
        guard let index = currentBooks.firstIndex(where: { $0.isbn13 == isbn13 }) else { return false }
        currentBooks.remove(at: index)
        return true
    }

    @discardableResult
    func toggle(_ book: BookSummary) -> Bool {
        if remove(isbn13: book.isbn13) {
            return false
        } else {
            add(book)
            return true
        }
    }

    // MARK: - Private

    private func persist() {
        guard let data = try? JSONEncoder().encode(currentBooks) else { return }
        userDefaults.set(data, forKey: storageKey)
    }

    private func notifyChange() {
        NotificationCenter.default.post(
            name: .bookshelfDidChange,
            object: self,
            userInfo: ["books": currentBooks]
        )
    }
}


