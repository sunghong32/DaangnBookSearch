//
//  BookDetailDTO.swift
//  DaangnBookSearch
//
//  Created by 민성홍 on 10/30/25.
//

import Foundation

struct BookDetailDTO: Decodable {
    let title: String
    let subtitle: String
    let authors: String
    let publisher: String
    let language: String
    let isbn10: String
    let isbn13: String
    let pages: String
    let year: String
    let rating: String
    let desc: String
    let price: String
    let image: String
    let url: String
    let pdf: [String: String]?
}

extension BookDetailDTO {
    func toDomain() -> BookDetail {
        var pdfURLs: [String: URL] = [:]
        if let pdf {
            for (name, link) in pdf {
                if let url = URL(string: link) {
                    pdfURLs[name] = url
                }
            }
        }

        return BookDetail(
            title: title,
            subtitle: subtitle,
            authors: authors,
            publisher: publisher,
            isbn10: isbn10,
            isbn13: isbn13,
            pages: pages,
            year: year,
            rating: rating,
            desc: desc,
            price: price,
            imageURL: URL(string: image),
            url: URL(string: url),
            pdfs: pdfURLs
        )
    }
}
