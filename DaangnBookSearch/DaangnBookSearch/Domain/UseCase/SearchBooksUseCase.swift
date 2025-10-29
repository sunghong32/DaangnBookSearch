//
//  SearchBooksUseCase.swift
//  DaangnBookSearch
//
//  Created by 민성홍 on 10/30/25.
//

import Foundation

struct SearchBooksUseCase {
    let repo: BookRepository
    func callAsFunction(query: String, page: Int) async throws -> (items: [BookSummary], total: Int, page: Int) {
        try await repo.search(query: query, page: page)
    }
}
