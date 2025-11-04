//
//  SearchBooksUseCase.swift
//  DaangnBookSearch
//
//  Created by 민성홍 on 10/30/25.
//

import Foundation

struct SearchBooksUseCase {
    let bookRepository: BookRepository

    /// memo: 검색어와 페이지로 도서 목록 조회
    func execute(
        query: String,
        page: Int
    ) async throws -> (items: [BookSummary], total: Int, page: Int) {
        try await bookRepository.search(query: query, page: page)
    }
}
