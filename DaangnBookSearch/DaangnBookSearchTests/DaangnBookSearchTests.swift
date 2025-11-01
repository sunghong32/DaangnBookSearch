//
//  DaangnBookSearchTests.swift
//  DaangnBookSearchTests
//
//  Created by Assistant on 11/02/25.
//

import XCTest
@testable import DaangnBookSearch

// MARK: - Network Layer Tests

final class NetworkProviderTests: XCTestCase {

    private var provider: NetworkProvider!

    override func setUp() {
        super.setUp()
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: configuration)
        provider = NetworkProvider(session: session)
    }

    override func tearDown() {
        super.tearDown()
        MockURLProtocol.requestHandler = nil
        provider = nil
    }

    func testRequestSuccessDecodesResponse() async throws {
        let expectation = expectation(description: "request")
        let sample = SampleDecodable(id: 1, title: "Sample")
        let data = try JSONEncoder().encode(sample)

        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.url?.path, "/mock")
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            expectation.fulfill()
            return (response, data)
        }

        let result: SampleDecodable = try await provider.request(MockNetworkTarget(), as: SampleDecodable.self)
        await fulfillment(of: [expectation], timeout: 1)

        XCTAssertEqual(result.id, 1)
        XCTAssertEqual(result.title, "Sample")
    }

    func testRequestWithServerErrorThrows() async {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 500,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data())
        }

        do {
            _ = try await provider.request(MockNetworkTarget(), as: SampleDecodable.self)
            XCTFail("Expected request to throw, but it succeeded")
        } catch {
            // Success: an error was thrown as expected
        }
    }
}

// MARK: - SearchViewModel Tests

@MainActor
final class SearchViewModelTests: XCTestCase {

    private var repository: MockBookRepository!
    private var store: BookshelfStore!
    private var userDefaults: UserDefaults!
    private var suiteName: String!

    override func setUp() {
        super.setUp()
        repository = MockBookRepository()
        suiteName = "search-view-model-tests-\(UUID().uuidString)"
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            XCTFail("Failed to create UserDefaults for test")
            return
        }
        userDefaults = defaults
        userDefaults.removePersistentDomain(forName: suiteName)
        store = BookshelfStore(userDefaults: userDefaults)
    }

    override func tearDown() {
        if let suiteName {
            userDefaults?.removePersistentDomain(forName: suiteName)
        }
        repository = nil
        store = nil
        userDefaults = nil
        suiteName = nil
        super.tearDown()
    }

    func testSearchSuccessUpdatesBooks() async {
        repository.searchHandler = { _, page in
            let books: [DaangnBookSearch.BookSummary] = [
                DaangnBookSearch.BookSummary(title: "Swift for Beginners", subtitle: "", isbn13: "1", price: "$10", imageURL: nil, url: nil)
            ]
            return (items: books, total: 1, page: page)
        }

        let useCase = SearchBooksUseCase(repo: repository)
        let viewModel = SearchViewModel(searchBooksUseCase: useCase, bookshelfStore: store)
        let expectation = expectation(description: "search")

        viewModel.setStateChangeHandler { state in
            if !state.isLoading, !state.books.isEmpty {
                XCTAssertEqual(state.books.count, 1)
                XCTAssertEqual(state.books.first?.title, "Swift for Beginners")
                expectation.fulfill()
            }
        }

        viewModel.send(SearchViewModel.Intent.updateQuery("Swift"))
        viewModel.send(SearchViewModel.Intent.search)

        await fulfillment(of: [expectation], timeout: 1)
    }

    func testLoadMoreAppendsBooks() async {
        repository.searchHandler = { _, page in
            if page == 1 {
                let items: [BookSummary] = [
                    BookSummary(title: "Page1", subtitle: "", isbn13: "1", price: "$10", imageURL: nil, url: nil)
                ]
                return (items: items, total: 2, page: page)
            } else {
                let items: [BookSummary] = [
                    BookSummary(title: "Page2", subtitle: "", isbn13: "2", price: "$12", imageURL: nil, url: nil)
                ]
                return (items: items, total: 2, page: page)
            }
        }

        let useCase = SearchBooksUseCase(repo: repository)
        let viewModel = SearchViewModel(searchBooksUseCase: useCase, bookshelfStore: store)
        let searchExpectation = expectation(description: "search")

        viewModel.setStateChangeHandler { state in
            if !state.isLoading, state.books.count == 1 {
                searchExpectation.fulfill()
            }
        }

        viewModel.send(SearchViewModel.Intent.updateQuery("Swift"))
        viewModel.send(SearchViewModel.Intent.search)

        await fulfillment(of: [searchExpectation], timeout: 1)

        let loadMoreExpectation = expectation(description: "load more")
        viewModel.setStateChangeHandler { state in
            if !state.isLoading, state.books.count == 2 {
                loadMoreExpectation.fulfill()
            }
        }

        viewModel.send(SearchViewModel.Intent.loadMore)
        await fulfillment(of: [loadMoreExpectation], timeout: 1)

        let titles = viewModel.state.books.map { $0.title }
        XCTAssertEqual(titles, ["Page1", "Page2"])
    }

    func testToggleFavoriteUpdatesState() async {
        let sample = DaangnBookSearch.BookSummary(title: "Favorite", subtitle: "", isbn13: "fav", price: "$0", imageURL: nil, url: nil)
        repository.searchHandler = { _, _ in
            let items: [DaangnBookSearch.BookSummary] = [sample]
            return (items: items, total: 1, page: 1)
        }

        let viewModel = SearchViewModel(searchBooksUseCase: SearchBooksUseCase(repo: repository), bookshelfStore: store)
        let expectation = expectation(description: "favorite")

        viewModel.setStateChangeHandler { state in
            if !state.isLoading, state.books.contains(where: { $0.isbn13 == sample.isbn13 }) {
                expectation.fulfill()
            }
        }


        viewModel.send(SearchViewModel.Intent.updateQuery("Fav"))
        viewModel.send(SearchViewModel.Intent.search)

        await fulfillment(of: [expectation], timeout: 1)

        viewModel.send(SearchViewModel.Intent.toggleFavorite(BookSummary(title: sample.title, subtitle: sample.subtitle, isbn13: sample.isbn13, price: sample.price, imageURL: sample.imageURL, url: sample.url)))
        await Task.yield()
        XCTAssertTrue(viewModel.state.favoriteISBNs.contains(sample.isbn13))
    }

    func testRefreshFavoritesLoadsFromStore() async {
        let sample = DaangnBookSearch.BookSummary(title: "Stored", subtitle: "", isbn13: "stored", price: "$0", imageURL: nil, url: nil)
        repository.searchHandler = { _, _ in
            let items: [DaangnBookSearch.BookSummary] = [sample]
            return (items: items, total: 1, page: 1)
        }

        _ = store.add(sample)

        let viewModel = SearchViewModel(searchBooksUseCase: SearchBooksUseCase(repo: repository), bookshelfStore: store)
        viewModel.send(SearchViewModel.Intent.refreshFavorites)

        XCTAssertTrue(viewModel.state.favoriteISBNs.contains(sample.isbn13))
    }
}

// MARK: - BookDetailViewModel Tests

@MainActor
final class BookDetailViewModelTests: XCTestCase {

    private var repository: MockBookRepository!

    override func setUp() {
        super.setUp()
        repository = MockBookRepository()
    }

    override func tearDown() {
        repository = nil
        super.tearDown()
    }

    func testLoadDetailSuccessUpdatesState() async {
        let detail = DaangnBookSearch.BookDetail(
            title: "Detail",
            subtitle: "",
            authors: "Tester",
            publisher: "Publisher",
            isbn10: "10",
            isbn13: "13",
            pages: "100",
            year: "2024",
            rating: "5",
            desc: "Description",
            price: "$5",
            imageURL: nil,
            url: nil,
            pdfs: [:]
        )

        repository.detailHandler = { _ in
            return detail
        }

        let viewModel = BookDetailViewModel(fetchBookDetailUseCase: FetchBookDetailUseCase(repo: repository))
        let expectation = expectation(description: "detail")

        viewModel.setStateChangeHandler { state in
            if !state.isLoading, let loaded = state.detail {
                XCTAssertEqual(loaded.title, detail.title)
                expectation.fulfill()
            }
        }

        viewModel.send(BookDetailViewModel.Intent.setISBN("13"))
        viewModel.send(BookDetailViewModel.Intent.load)

        await fulfillment(of: [expectation], timeout: 1)
    }

    func testLoadDetailFailureSetsErrorMessage() async {
        repository.detailHandler = { _ in throw MockError.stub }
        let viewModel = BookDetailViewModel(fetchBookDetailUseCase: FetchBookDetailUseCase(repo: repository))
        let expectation = expectation(description: "error")

        viewModel.setStateChangeHandler { state in
            if !state.isLoading, state.errorMessage != nil {
                expectation.fulfill()
            }
        }

        viewModel.send(BookDetailViewModel.Intent.setISBN("13"))
        viewModel.send(BookDetailViewModel.Intent.load)

        await fulfillment(of: [expectation], timeout: 1)
    }
}

// MARK: - UseCase Tests (Domain)

final class SearchBooksUseCaseTests: XCTestCase {

    func test_searchBooks_usecase_returns_items() async throws {
        // given
        let repo = MockBookRepository()
        repo.searchHandler = { query, page in
            XCTAssertEqual(query, "Swift")
            return (
                items: [BookSummary(title: "Swift", subtitle: "", isbn13: "1", price: "$0", imageURL: nil, url: nil)],
                total: 1,
                page: page
            )
        }
        let useCase = SearchBooksUseCase(repo: repo)

        // when
        let result = try await useCase(query: "Swift", page: 1)

        // then
        XCTAssertEqual(result.items.count, 1)
        XCTAssertEqual(result.items.first?.title, "Swift")
    }
}

final class FetchBookDetailUseCaseTests: XCTestCase {

    func test_fetchDetail_returns_detail() async throws {
        // given
        let repo = MockBookRepository()
        let expected = BookDetail(
            title: "Detail",
            subtitle: "",
            authors: "Tester",
            publisher: "Pub",
            isbn10: "10",
            isbn13: "13",
            pages: "100",
            year: "2025",
            rating: "5",
            desc: "desc",
            price: "$1",
            imageURL: nil,
            url: nil,
            pdfs: [:]
        )
        repo.detailHandler = { isbn in
            XCTAssertEqual(isbn, "13")
            return expected
        }
        let useCase = FetchBookDetailUseCase(repo: repo)

        // when
        let detail = try await useCase(isbn13: "13")

        // then
        XCTAssertEqual(detail.title, expected.title)
        XCTAssertEqual(detail.isbn13, expected.isbn13)
    }
}

// MARK: - Bookshelf Store / ViewModel Tests

@MainActor
final class BookshelfStoreTests: XCTestCase {

    func testAddRemoveToggle() {
        let suite = "bookshelf-store-tests-\(UUID().uuidString)"
        guard let defaults = UserDefaults(suiteName: suite) else {
            XCTFail("Failed to create UserDefaults for test")
            return
        }
        defaults.removePersistentDomain(forName: suite)
        defer { defaults.removePersistentDomain(forName: suite) }

        let store = BookshelfStore(userDefaults: defaults)
        let book = DaangnBookSearch.BookSummary(title: "Bookmark", subtitle: "", isbn13: "bookmark", price: "$0", imageURL: nil, url: nil)

        XCTAssertFalse(store.contains(isbn13: book.isbn13))
        XCTAssertTrue(store.add(book))
        XCTAssertTrue(store.contains(isbn13: book.isbn13))
        XCTAssertFalse(store.add(book))

        XCTAssertFalse(store.toggle(book)) // remove
        XCTAssertFalse(store.contains(isbn13: book.isbn13))
    }
}

@MainActor
final class BookshelfViewModelTests: XCTestCase {

    private var store: BookshelfStore!
    private var userDefaults: UserDefaults!
    private var suiteName: String!

    override func setUp() {
        super.setUp()
        suiteName = "bookshelf-view-model-tests-\(UUID().uuidString)"
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            XCTFail("Failed to create UserDefaults for test")
            return
        }
        userDefaults = defaults
        userDefaults.removePersistentDomain(forName: suiteName)
        store = BookshelfStore(userDefaults: userDefaults)
    }

    override func tearDown() {
        if let suiteName {
            userDefaults?.removePersistentDomain(forName: suiteName)
        }
        store = nil
        userDefaults = nil
        suiteName = nil
        super.tearDown()
    }

    func testLoadReflectsStoredBooks() {
        let book = DaangnBookSearch.BookSummary(title: "My Book", subtitle: "", isbn13: "book1", price: "$1", imageURL: nil, url: nil)
        _ = store.add(book)

        let viewModel = BookshelfViewModel(bookshelfStore: store)
        viewModel.send(BookshelfViewModel.Intent.load)

        XCTAssertEqual(viewModel.state.books.count, 1)
        XCTAssertEqual(viewModel.state.books.first?.isbn13, "book1")
    }

    func testRemoveUpdatesState() {
        let book = DaangnBookSearch.BookSummary(title: "My Book", subtitle: "", isbn13: "book1", price: "$1", imageURL: nil, url: nil)
        _ = store.add(book)

        let viewModel = BookshelfViewModel(bookshelfStore: store)
        viewModel.send(BookshelfViewModel.Intent.load)
        viewModel.send(BookshelfViewModel.Intent.remove(book))

        XCTAssertTrue(viewModel.state.books.isEmpty)
    }
}

// MARK: - Test Utilities

private struct MockNetworkTarget: NetworkTarget {
    var baseURL: URL { URL(string: "https://example.com")! }
    var path: String { "/mock" }
    var method: HTTPMethod { .get }
    var headers: [String : String]? { nil }
    var body: Data? { nil }
    var queryItems: [URLQueryItem]? { nil }
}

private struct SampleDecodable: Codable, Equatable {
    let id: Int
    let title: String
}

private enum MockError: Error {
    case stub
}

private final class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handler = Self.requestHandler else {
            fatalError("Request handler not set")
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() { }
}

private final class MockBookRepository: BookRepository {
    // Handlers allow tests to control behavior
    var searchHandler: ((String, Int) async throws -> (items: [BookSummary], total: Int, page: Int))?
    var detailHandler: ((String) async throws -> BookDetail)?

    // Conformance to BookRepository
    func search(query: String, page: Int) async throws -> (items: [BookSummary], total: Int, page: Int) {
        guard let handler = self.searchHandler else {
            return (items: [], total: 0, page: page)
        }
        let result = try await handler(query, page)
        let items: [BookSummary] = result.items
        let total: Int = result.total
        let currentPage: Int = result.page
        return (items: items, total: total, page: currentPage)
    }

    func detail(isbn13: String) async throws -> BookDetail {
        guard let handler = self.detailHandler else {
            throw MockError.stub
        }
        let detail: BookDetail = try await handler(isbn13)
        return detail
    }
}

