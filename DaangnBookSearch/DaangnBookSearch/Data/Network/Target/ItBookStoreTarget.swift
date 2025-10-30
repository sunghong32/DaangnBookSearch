//
//  ItBookStoreTarget.swift
//  DaangnBookSearch
//
//  Created by 민성홍 on 10/30/25.
//

import Foundation

enum ItBookStoreTarget: NetworkTarget {
    case search(query: String, page: Int)
    case detail(isbn13: String)

    var baseURL: URL {
        URL(string: "https://api.itbook.store/1.0")!
    }

    var path: String {
        switch self {
        case let .search(query, page):
            let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? query
            return "/search/\(encodedQuery)/\(page)"
        case let .detail(isbn13):
            return "/books/\(isbn13)"
        }
    }

    var method: HTTPMethod { .get }

    var headers: [String : String]? {
        ["Accept": "application/json"]
    }

    var queryItems: [URLQueryItem]? { nil }

    var body: Data? { nil }
}
