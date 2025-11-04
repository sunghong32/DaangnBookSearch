import Foundation

final class MockBookRepository: BookRepository {
    struct SearchCall {
        let query: String
        let page: Int
    }

    private(set) var receivedSearchCalls: [SearchCall] = []
    private(set) var receivedDetailISBNs: [String] = []
    var searchResult: Result<(items: [BookSummary], total: Int, page: Int), Error> = .success((items: [], total: 0, page: 0))
    var detailResult: Result<BookDetail, Error> = .failure(MockError.missingDetailStub)

    func search(query: String, page: Int) async throws -> (items: [BookSummary], total: Int, page: Int) {
        receivedSearchCalls.append(.init(query: query, page: page))
        return try searchResult.get()
    }

    func detail(isbn13: String) async throws -> BookDetail {
        receivedDetailISBNs.append(isbn13)
        return try detailResult.get()
    }
}

final class MockBookshelfRepository: BookshelfRepository {
    private(set) var loadCallCount = 0
    private(set) var saveCalls: [[BookSummary]] = []
    var loadResult: Result<[BookSummary], Error> = .success([])
    var saveError: Error?

    func loadBooks() async throws -> [BookSummary] {
        loadCallCount += 1
        return try loadResult.get()
    }

    func saveBooks(_ books: [BookSummary]) async throws {
        saveCalls.append(books)
        if let saveError {
            throw saveError
        }
    }
}

enum MockError: Error {
    case missingDetailStub
}

extension BookSummary {
    static func fixture(
        title: String = "Swift Handbook",
        subtitle: String = "All-in-One",
        isbn13: String,
        price: String = "$0",
        imageURL: URL? = URL(string: "https://example.com/thumb.png"),
        url: URL? = URL(string: "https://example.com/detail")
    ) -> BookSummary {
        BookSummary(
            title: title,
            subtitle: subtitle,
            isbn13: isbn13,
            price: price,
            imageURL: imageURL,
            url: url
        )
    }
}

extension BookDetail {
    static func fixture(
        title: String = "Swift Handbook",
        subtitle: String = "All-in-One",
        authors: String = "Daangn Writers",
        publisher: String = "Daangn",
        isbn10: String = "1234567890",
        isbn13: String,
        pages: String = "352",
        year: String = "2025",
        rating: String = "4.5",
        desc: String = "Everything about Swift",
        price: String = "$49.99",
        imageURL: URL? = URL(string: "https://example.com/detail.png"),
        url: URL? = URL(string: "https://example.com/detail"),
        pdfs: [String: URL] = ["Preview": URL(string: "https://example.com/preview.pdf")!]
    ) -> BookDetail {
        BookDetail(
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
            imageURL: imageURL,
            url: url,
            pdfs: pdfs
        )
    }
}

