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
struct LoadBookshelfUseCase {
    
    let bookshelfStore: BookshelfStore
    let repository: BookshelfRepository
    
    func callAsFunction() async throws {
        let savedBooks = try await repository.loadBooks()
        await bookshelfStore.updateBooks(savedBooks)
    }
}

