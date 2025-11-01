//
//  BookshelfStore.swift
//  DaangnBookSearch
//
//  Created by Assistant on 11/02/25.
//

import Foundation

final class BookshelfStore {

    static let shared = BookshelfStore()

    private let userDefaults: UserDefaults
    private let storageKey = "bookshelf.items"
    private var storedBooks: [BookSummary] {
        didSet {
            persist()
        }
    }

    var currentBooks: [BookSummary] {
        storedBooks
    }

    // MARK: - Init

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        if
            let data = userDefaults.data(forKey: storageKey),
            let decoded = try? JSONDecoder().decode([BookSummary].self, from: data)
        {
            storedBooks = decoded
        } else {
            storedBooks = []
        }
    }

    // MARK: - Public API

    func contains(isbn13: String) -> Bool {
        storedBooks.contains { $0.isbn13 == isbn13 }
    }

    @discardableResult
    func add(_ book: BookSummary) -> Bool {
        guard contains(isbn13: book.isbn13) == false else { return false }
        storedBooks.insert(book, at: 0)
        return true
    }

    @discardableResult
    func remove(isbn13: String) -> Bool {
        guard let index = storedBooks.firstIndex(where: { $0.isbn13 == isbn13 }) else { return false }
        storedBooks.remove(at: index)
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
        guard let data = try? JSONEncoder().encode(storedBooks) else { return }
        userDefaults.set(data, forKey: storageKey)
    }
}


