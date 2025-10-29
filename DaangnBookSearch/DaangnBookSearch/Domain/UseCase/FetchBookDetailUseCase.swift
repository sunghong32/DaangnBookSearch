//
//  FetchBookDetailUseCase.swift
//  DaangnBookSearch
//
//  Created by 민성홍 on 10/30/25.
//

import Foundation

struct FetchBookDetailUseCase {
    let repo: BookRepository
    func callAsFunction(isbn13: String) async throws -> BookDetail {
        try await repo.detail(isbn13: isbn13)
    }
}
