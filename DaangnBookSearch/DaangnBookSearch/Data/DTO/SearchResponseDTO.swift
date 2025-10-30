//
//  SearchResponseDTO.swift
//  DaangnBookSearch
//
//  Created by 민성홍 on 10/30/25.
//

import Foundation

struct SearchResponseDTO: Decodable {
    let total: String
    let page: String
    let books: [SearchBookDTO]
}

// Domain 매핑 (예: BookSummary, 페이지 정보)
extension SearchResponseDTO {
    func toDomain() -> (items: [BookSummary], total: Int, page: Int) {
        let items = books.map { $0.toDomain() }
        let totalInt = Int(total) ?? 0
        let pageInt = Int(page) ?? 1
        return (items, totalInt, pageInt)
    }
}
