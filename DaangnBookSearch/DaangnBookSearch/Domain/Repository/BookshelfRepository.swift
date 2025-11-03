//
//  BookshelfRepository.swift
//  DaangnBookSearch
//
//  Created by Assistant on 11/02/25.
//

import Foundation

/// 즐겨찾기 데이터의 영구 저장을 담당하는 Repository 프로토콜
///
/// Data 계층에서 구현 (UserDefaults, Core Data 등)
protocol BookshelfRepository {
    
    func loadBooks() async throws -> [BookSummary]
    func saveBooks(_ books: [BookSummary]) async throws
}

