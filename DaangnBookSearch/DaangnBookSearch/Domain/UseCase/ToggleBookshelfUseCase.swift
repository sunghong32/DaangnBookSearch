//
//  ToggleBookshelfUseCase.swift
//  DaangnBookSearch
//
//  Created by Assistant on 11/02/25.
//

import Foundation

/// 즐겨찾기 토글 기능을 수행하는 UseCase
///
/// ViewModel은 Store를 직접 변경하지 않고 이 UseCase를 통해서만 접근
/// Store 업데이트 후 자동으로 영구 저장소에도 반영됨
struct ToggleBookshelfUseCase {
    
    let bookshelfStore: BookshelfStore
    let repository: BookshelfRepository
    
    func callAsFunction(book: BookSummary) async throws -> Bool {
        let isFavorite = await bookshelfStore.toggle(book)
        
        // 영구 저장소에 저장
        let currentBooks = await bookshelfStore.currentBooks
        try await repository.saveBooks(currentBooks)
        
        return isFavorite
    }
}

