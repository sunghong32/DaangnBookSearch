//
//  BookshelfRepository.swift
//  DaangnBookSearch
//
//  Created by Assistant on 11/02/25.
//

import Foundation

protocol BookshelfRepository {
    /// memo: 저장된 즐겨찾기 로딩
    func loadBooks() async throws -> [BookSummary]
    /// memo: 즐겨찾기 목록을 영구 저장
    func saveBooks(_ books: [BookSummary]) async throws
}

