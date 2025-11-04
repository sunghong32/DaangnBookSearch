//
//  ToggleBookshelfUseCase.swift
//  DaangnBookSearch
//
//  Created by Assistant on 11/02/25.
//

import Foundation

struct ToggleBookshelfUseCase {
    
    let bookshelfStore: BookshelfStore
    let repository: BookshelfRepository
    
    /// memo: 즐겨찾기 토글 상태를 Store와 저장소에 동기화
    @discardableResult
    func execute(book: BookSummary) async throws -> Bool {
        let isFavorite = await bookshelfStore.toggle(book)
        
        // 영구 저장소에 저장
        let currentBooks = await bookshelfStore.currentBooks
        try await repository.saveBooks(currentBooks)
        
        return isFavorite
    }
}

