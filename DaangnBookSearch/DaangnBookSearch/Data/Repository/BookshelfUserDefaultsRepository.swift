//
//  BookshelfUserDefaultsRepository.swift
//  DaangnBookSearch
//
//  Created by Assistant on 11/02/25.
//

import Foundation

/// UserDefaults를 사용하여 즐겨찾기를 저장하는 Repository 구현체
///
/// JSON 형태로 저장하며, 테스트 시 UserDefaults 주입 가능
final class BookshelfUserDefaultsRepository: BookshelfRepository {
    
    private let userDefaults: UserDefaults
    private let storageKey = "bookshelf.items"
    
    /// 테스트 시 테스트용 UserDefaults 주입 가능
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    func loadBooks() async throws -> [BookSummary] {
        guard let data = userDefaults.data(forKey: storageKey) else {
            return []
        }
        
        let decoder = JSONDecoder()
        let books = try decoder.decode([BookSummary].self, from: data)
        return books
    }
    
    func saveBooks(_ books: [BookSummary]) async throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(books)
        userDefaults.set(data, forKey: storageKey)
    }
}

