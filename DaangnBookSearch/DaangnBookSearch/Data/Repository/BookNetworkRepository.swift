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

    /// memo: 검색 API 호출 후 도메인 모델 변환
    func search(
        query: String,
        page: Int
    ) async throws -> (items: [BookSummary], total: Int, page: Int) {
        let target = ItBookStoreTarget.search(query: query, page: page)
        let responseDTO: SearchResponseDTO = try await provider.request(target, as: SearchResponseDTO.self)
        return responseDTO.toDomain()
    }

    /// memo: 상세 API 호출 후 도메인 모델 반환
    func detail(
        isbn13: String
    ) async throws -> BookDetail {
        let target = ItBookStoreTarget.detail(isbn13: isbn13)
        let detailDTO: BookDetailDTO = try await provider.request(target, as: BookDetailDTO.self)
        return detailDTO.toDomain()
    }
}
