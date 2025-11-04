//
//  BookDetail.swift
//  DaangnBookSearch
//
//  Created by 민성홍 on 10/30/25.
//

import Foundation

public struct BookDetail: Codable, Equatable {
    public let title: String
    public let subtitle: String
    public let authors: String
    public let publisher: String
    public let isbn10: String
    public let isbn13: String
    public let pages: String
    public let year: String
    public let rating: String
    public let desc: String
    public let price: String
    public let imageURL: URL?
    public let url: URL?
    public let pdfs: [String: URL]
    
    public init(
        title: String,
        subtitle: String,
        authors: String,
        publisher: String,
        isbn10: String,
        isbn13: String,
        pages: String,
        year: String,
        rating: String,
        desc: String,
        price: String,
        imageURL: URL?,
        url: URL?,
        pdfs: [String: URL]
    ) {
        self.title = title
        self.subtitle = subtitle
        self.authors = authors
        self.publisher = publisher
        self.isbn10 = isbn10
        self.isbn13 = isbn13
        self.pages = pages
        self.year = year
        self.rating = rating
        self.desc = desc
        self.price = price
        self.imageURL = imageURL
        self.url = url
        self.pdfs = pdfs
    }
}
