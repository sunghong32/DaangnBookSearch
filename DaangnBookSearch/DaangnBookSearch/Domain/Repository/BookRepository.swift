//
//  BookRepository.swift
//  DaangnBookSearch
//
//  Created by 민성홍 on 10/30/25.
//

import Foundation

protocol BookRepository {
    func search(
        query: String,
        page: Int
    ) async throws -> (items: [BookSummary], total: Int, page: Int)
    
    func detail(isbn13: String) async throws -> BookDetail
}
