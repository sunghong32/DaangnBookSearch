//
//  BookNetworkRepository.swift
//  DaangnBookSearch
//
//  Created by 민성홍 on 10/30/25.
//

import Foundation

final class BookNetworkRepository: BookRepository {

    private let provider: NetworkProvider

    init(provider: NetworkProvider) {
        self.provider = provider
    }

    // 검색
    func search(
        query: String,
        page: Int
    ) async throws -> (items: [BookSummary], total: Int, page: Int) {

        let target = ItBookStoreTarget.search(query: query, page: page)
        let dto: SearchResponseDTO = try await provider.request(target)
        return dto.toDomain()
    }

    func detail(isbn13: String) async throws -> BookDetail {
        let target = ItBookStoreTarget.detail(isbn13: isbn13)
        let dto: BookDetailDTO = try await provider.request(target) 
        return dto.toDomain()
    }
}
