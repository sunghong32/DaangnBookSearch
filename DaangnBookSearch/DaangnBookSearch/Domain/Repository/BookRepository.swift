//
//  BookRepository.swift
//  DaangnBookSearch
//
//  Created by 민성홍 on 10/30/25.
//

import Foundation

public protocol BookRepository {
    /// memo: 검색어와 페이지로 목록 조회
    func search(
        query: String,
        page: Int
    ) async throws -> (items: [BookSummary], total: Int, page: Int)
    
    /// memo: ISBN13으로 상세 정보 조회
    func detail(isbn13: String) async throws -> BookDetail
}
