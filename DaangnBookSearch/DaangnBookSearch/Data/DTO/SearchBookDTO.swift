//
//  SearchBookDTO.swift
//  DaangnBookSearch
//
//  Created by 민성홍 on 10/30/25.
//

import Foundation

struct SearchBookDTO: Decodable {
    let title: String
    let subtitle: String
    let isbn13: String
    let price: String
    let image: String
    let url: String
}

extension SearchBookDTO {
    func toDomain() -> BookSummary {
        return BookSummary(
            isbn13: isbn13,
            title: title,
            subtitle: subtitle,
            imageURL: URL(string: image),
            priceText: price
        )
    }
}
