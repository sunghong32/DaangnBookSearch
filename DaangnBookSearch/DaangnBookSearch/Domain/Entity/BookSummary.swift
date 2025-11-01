//
//  BookSummary.swift
//  DaangnBookSearch
//
//  Created by 민성홍 on 10/30/25.
//

import Foundation

struct BookSummary: Hashable, Codable {
    let title: String
    let subtitle: String
    let isbn13: String
    let price: String
    let imageURL: URL?
    let url: URL?
}
