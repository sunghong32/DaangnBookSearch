//
//  LoadBookshelfUseCase.swift
//  DaangnBookSearch
//
//  Created by Assistant on 11/02/25.
//

import Foundation

/// 저장된 즐겨찾기를 불러와서 Store에 반영하는 UseCase
///
/// 앱 시작 시 SceneDelegate에서 호출
public struct LoadBookshelfUseCase {
    
    private let bookshelfStore: BookshelfStore
    private let repository: BookshelfRepository
    
    public init(bookshelfStore: BookshelfStore, repository: BookshelfRepository) {
        self.bookshelfStore = bookshelfStore
        self.repository = repository
    }
 
    /// memo: 저장된 즐겨찾기 목록을 불러와 Store 업데이트
    public func execute() async throws {
        let savedBooks = try await repository.loadBooks()
        await bookshelfStore.updateBooks(savedBooks)
    }
}

