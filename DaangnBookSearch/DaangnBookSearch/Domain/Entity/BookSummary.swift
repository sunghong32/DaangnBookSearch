//
//  BookSummary.swift
//  DaangnBookSearch
//
//  Created by 민성홍 on 10/30/25.
//

import Foundation

public struct BookSummary: Hashable, Codable {
    public let title: String
    public let subtitle: String
    public let isbn13: String
    public let price: String
    public let imageURL: URL?
    public let url: URL?
    
    public init(
        title: String,
        subtitle: String,
        isbn13: String,
        price: String,
        imageURL: URL?,
        url: URL?
    ) {
        self.title = title
        self.subtitle = subtitle
        self.isbn13 = isbn13
        self.price = price
        self.imageURL = imageURL
        self.url = url
    }
}
