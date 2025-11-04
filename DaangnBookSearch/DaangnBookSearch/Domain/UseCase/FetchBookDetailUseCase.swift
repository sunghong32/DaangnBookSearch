//
//  FetchBookDetailUseCase.swift
//  DaangnBookSearch
//
//  Created by 민성홍 on 10/30/25.
//

import Foundation

struct FetchBookDetailUseCase {
    let bookRepository: BookRepository

    /// memo: ISBN13 기반으로 상세 정보 요청
    func execute(isbn13: String) async throws -> BookDetail {
        try await bookRepository.detail(isbn13: isbn13)
    }
}
