//
//  DaangnBookSearchTests.swift
//  DaangnBookSearchTests
//
//  Created by Assistant on 11/02/25.
//

import XCTest
@testable import DaangnBookSearch

// MARK: - SearchViewModelTests

final class SearchViewModelTests: XCTestCase {

    @MainActor
    func testSearchSuccessUpdatesStateWithFetchedBooks() async throws {
        // given
        let bookRepository = MockBookRepository()
        let books = [
            BookSummary.stub(title: "Swift Concurrency", subtitle: "Modern Async Patterns", isbn13: "111", price: "$10"),
            BookSummary.stub(title: "iOS Unit Testing", subtitle: "XCTest in Practice", isbn13: "222", price: "$12")
        ]
        bookRepository.searchResult = (items: books, total: 2, page: 1)
        let searchBooksUseCase = SearchBooksUseCase(bookRepository: bookRepository)

        let suiteName = "SearchViewModelTests.success"
        guard let userDefaults = UserDefaults(suiteName: suiteName) else {
            XCTFail("Failed to create UserDefaults suite")
            return
        }
        userDefaults.removePersistentDomain(forName: suiteName)
        defer { userDefaults.removePersistentDomain(forName: suiteName) }

        let bookshelfStore = BookshelfStore()
        let bookshelfRepository = BookshelfUserDefaultsRepository(userDefaults: userDefaults)
        let toggleBookshelfUseCase = ToggleBookshelfUseCase(bookshelfStore: bookshelfStore, repository: bookshelfRepository)
        let searchViewModel = SearchViewModel(
            searchBooksUseCase: searchBooksUseCase,
            toggleBookshelfUseCase: toggleBookshelfUseCase,
            bookshelfStore: bookshelfStore
        )

        let expectation = expectation(description: "Search results delivered")

        searchViewModel.setStateChangeHandler { state in
            if !state.isLoading, state.books == books {
                XCTAssertEqual(state.page, 1)
                XCTAssertEqual(state.total, 2)
                XCTAssertNil(state.errorMessage)
                expectation.fulfill()
            }
        }

        // when
        searchViewModel.send(SearchViewModel.Intent.updateQuery("Swift"))
        searchViewModel.send(SearchViewModel.Intent.search)

        // then
        await fulfillment(of: [expectation], timeout: 1.0)
        XCTAssertEqual(bookRepository.searchCallCount, 1)
    }

    @MainActor
    func testSearchFailureSetsErrorMessage() async throws {
        // given
        let bookRepository = MockBookRepository()
        bookRepository.searchError = MockError.searchFailed
        let searchBooksUseCase = SearchBooksUseCase(bookRepository: bookRepository)

        let suiteName = "SearchViewModelTests.failure"
        guard let userDefaults = UserDefaults(suiteName: suiteName) else {
            XCTFail("Failed to create UserDefaults suite")
            return
        }
        userDefaults.removePersistentDomain(forName: suiteName)
        defer { userDefaults.removePersistentDomain(forName: suiteName) }

        let bookshelfStore = BookshelfStore()
        let bookshelfRepository = BookshelfUserDefaultsRepository(userDefaults: userDefaults)
        let toggleBookshelfUseCase = ToggleBookshelfUseCase(bookshelfStore: bookshelfStore, repository: bookshelfRepository)
        let searchViewModel = SearchViewModel(
            searchBooksUseCase: searchBooksUseCase,
            toggleBookshelfUseCase: toggleBookshelfUseCase,
            bookshelfStore: bookshelfStore
        )

        let expectation = expectation(description: "Error state delivered")

        searchViewModel.setStateChangeHandler { state in
            if !state.isLoading, let message = state.errorMessage {
                XCTAssertEqual(message, "검색 결과를 불러오지 못했습니다.")
                XCTAssertTrue(state.books.isEmpty)
                expectation.fulfill()
            }
        }

        // when
        searchViewModel.send(SearchViewModel.Intent.updateQuery("Swift"))
        searchViewModel.send(SearchViewModel.Intent.search)

        // then
        await fulfillment(of: [expectation], timeout: 1.0)
        XCTAssertEqual(bookRepository.searchCallCount, 1)
    }

    @MainActor
    func testSearchWithEmptyQueryDoesNotTriggerNetworkCall() {
        // given
        let bookRepository = MockBookRepository()
        let searchBooksUseCase = SearchBooksUseCase(bookRepository: bookRepository)

        let suiteName = "SearchViewModelTests.emptyQuery"
        guard let userDefaults = UserDefaults(suiteName: suiteName) else {
            XCTFail("Failed to create UserDefaults suite")
            return
        }
        userDefaults.removePersistentDomain(forName: suiteName)
        defer { userDefaults.removePersistentDomain(forName: suiteName) }

        let bookshelfStore = BookshelfStore()
        let bookshelfRepository = BookshelfUserDefaultsRepository(userDefaults: userDefaults)
        let toggleBookshelfUseCase = ToggleBookshelfUseCase(bookshelfStore: bookshelfStore, repository: bookshelfRepository)
        let searchViewModel = SearchViewModel(
            searchBooksUseCase: searchBooksUseCase,
            toggleBookshelfUseCase: toggleBookshelfUseCase,
            bookshelfStore: bookshelfStore
        )

        // when
        searchViewModel.send(SearchViewModel.Intent.search)

        // then
        XCTAssertEqual(bookRepository.searchCallCount, 0)
    }
}

// MARK: - BookDetailViewModelTests

final class BookDetailViewModelTests: XCTestCase {

    @MainActor
    func testLoadSuccessUpdatesDetailState() async {
        // given
        let bookRepository = MockBookRepository()
        let detail = BookDetail.stub(isbn13: "999")
        bookRepository.detailResult = detail
        let fetchBookDetailUseCase = FetchBookDetailUseCase(bookRepository: bookRepository)
        let bookDetailViewModel = BookDetailViewModel(fetchBookDetailUseCase: fetchBookDetailUseCase)

        let expectation = expectation(description: "Book detail loaded")

        bookDetailViewModel.setStateChangeHandler { state in
            if !state.isLoading, let loadedDetail = state.detail, loadedDetail.isbn13 == detail.isbn13 {
                XCTAssertNil(state.errorMessage)
                expectation.fulfill()
            }
        }

        // when
        bookDetailViewModel.send(BookDetailViewModel.Intent.setISBN("999"))
        bookDetailViewModel.send(BookDetailViewModel.Intent.load)

        // then
        await fulfillment(of: [expectation], timeout: 1.0)
        XCTAssertEqual(bookRepository.detailCallCount, 1)
    }

    @MainActor
    func testLoadFailureSetsErrorMessage() async {
        // given
        let bookRepository = MockBookRepository()
        bookRepository.detailError = MockError.detailFailed
        let fetchBookDetailUseCase = FetchBookDetailUseCase(bookRepository: bookRepository)
        let bookDetailViewModel = BookDetailViewModel(fetchBookDetailUseCase: fetchBookDetailUseCase)

        let expectation = expectation(description: "Book detail failed")

        bookDetailViewModel.setStateChangeHandler { state in
            if !state.isLoading, let message = state.errorMessage {
                XCTAssertEqual(message, "상세 정보를 불러오지 못했습니다.")
                XCTAssertNil(state.detail)
                expectation.fulfill()
            }
        }

        // when
        bookDetailViewModel.send(BookDetailViewModel.Intent.setISBN("999"))
        bookDetailViewModel.send(BookDetailViewModel.Intent.load)

        // then
        await fulfillment(of: [expectation], timeout: 1.0)
        XCTAssertEqual(bookRepository.detailCallCount, 1)
    }

    func testLoadWithoutISBNDoesNotCallRepository() {
        // given
        let bookRepository = MockBookRepository()
        let fetchBookDetailUseCase = FetchBookDetailUseCase(bookRepository: bookRepository)
        let bookDetailViewModel = BookDetailViewModel(fetchBookDetailUseCase: fetchBookDetailUseCase)

        // when
        bookDetailViewModel.send(BookDetailViewModel.Intent.load)

        // then
        XCTAssertEqual(bookRepository.detailCallCount, 0)
    }
}

// MARK: - BookshelfViewModelTests

final class BookshelfViewModelTests: XCTestCase {

    @MainActor
    func testLoadIntentRefreshesStateFromStore() async {
        // given
        let suiteName = "BookshelfViewModelTests.load"
        guard let userDefaults = UserDefaults(suiteName: suiteName) else {
            XCTFail("Failed to create UserDefaults suite")
            return
        }
        userDefaults.removePersistentDomain(forName: suiteName)
        defer { userDefaults.removePersistentDomain(forName: suiteName) }

        let bookshelfStore = BookshelfStore()
        let expectedBooks = [
            BookSummary.stub(title: "Clean Architecture", subtitle: "Robert C. Martin", isbn13: "101", price: "$30"),
            BookSummary.stub(title: "Refactoring", subtitle: "Martin Fowler", isbn13: "202", price: "$28")
        ]
        await bookshelfStore.updateBooks(expectedBooks)

        let bookshelfRepository = BookshelfUserDefaultsRepository(userDefaults: userDefaults)
        let toggleBookshelfUseCase = ToggleBookshelfUseCase(bookshelfStore: bookshelfStore, repository: bookshelfRepository)
        let bookshelfViewModel = BookshelfViewModel(
            bookshelfStore: bookshelfStore,
            toggleBookshelfUseCase: toggleBookshelfUseCase
        )
        let expectation = expectation(description: "Bookshelf state refreshed")

        bookshelfViewModel.setStateChangeHandler { state in
            if state.books == expectedBooks {
                expectation.fulfill()
            }
        }

        // when
        bookshelfViewModel.send(BookshelfViewModel.Intent.load)

        // then
        wait(for: [expectation], timeout: 0.5)
        let currentBooks = await bookshelfStore.currentBooks
        XCTAssertEqual(currentBooks, expectedBooks)
    }

    @MainActor
    func testRemoveIntentUpdatesStoreAndState() async {
        // given
        let suiteName = "BookshelfViewModelTests.remove"
        guard let userDefaults = UserDefaults(suiteName: suiteName) else {
            XCTFail("Failed to create UserDefaults suite")
            return
        }
        userDefaults.removePersistentDomain(forName: suiteName)
        defer { userDefaults.removePersistentDomain(forName: suiteName) }

        let bookshelfStore = BookshelfStore()
        let bookA = BookSummary.stub(title: "Test-Driven Development", subtitle: "Kent Beck", isbn13: "303", price: "$24")
        let bookB = BookSummary.stub(title: "The Pragmatic Programmer", subtitle: "Andy Hunt", isbn13: "404", price: "$26")
        await bookshelfStore.updateBooks([bookA, bookB])

        let bookshelfRepository = BookshelfUserDefaultsRepository(userDefaults: userDefaults)
        let toggleBookshelfUseCase = ToggleBookshelfUseCase(bookshelfStore: bookshelfStore, repository: bookshelfRepository)
        let bookshelfViewModel = BookshelfViewModel(
            bookshelfStore: bookshelfStore,
            toggleBookshelfUseCase: toggleBookshelfUseCase
        )
        let expectation = expectation(description: "Bookshelf item removed")

        bookshelfViewModel.setStateChangeHandler { state in
            if state.books == [bookB] {
                expectation.fulfill()
            }
        }

        // when
        bookshelfViewModel.send(BookshelfViewModel.Intent.remove(bookA))

        // then
        wait(for: [expectation], timeout: 0.5)
        let currentBooks = await bookshelfStore.currentBooks
        XCTAssertEqual(currentBooks, [bookB])
    }
}

// MARK: - Test Doubles

private enum MockError: Error {
    case searchFailed
    case notImplemented
    case detailFailed
}

private final class MockBookRepository: BookRepository {

    var searchResult: (items: [BookSummary], total: Int, page: Int)?
    var searchError: Error?
    private(set) var searchCallCount = 0

    var detailResult: BookDetail?
    var detailError: Error?
    private(set) var detailCallCount = 0

    func search(query: String, page: Int) async throws -> (items: [BookSummary], total: Int, page: Int) {
        searchCallCount += 1

        if let error = searchError {
            throw error
        }

        if let result = searchResult {
            return result
        }

        return ([], 0, page)
    }

    func detail(isbn13: String) async throws -> BookDetail {
        detailCallCount += 1

        if let error = detailError {
            throw error
        }

        if let detail = detailResult {
            return detail
        }

        throw MockError.notImplemented
    }
}

private extension BookSummary {
    static func stub(
        title: String,
        subtitle: String,
        isbn13: String,
        price: String,
        imageURL: URL? = URL(string: "https://example.com/cover.jpg"),
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

private extension BookDetail {
    static func stub(
        title: String = "Sample Title",
        subtitle: String = "Sample Subtitle",
        authors: String = "Author",
        publisher: String = "Publisher",
        isbn10: String = "1234567890",
        isbn13: String,
        pages: String = "350",
        year: String = "2024",
        rating: String = "4",
        desc: String = "Description",
        price: String = "$20",
        imageURL: URL? = URL(string: "https://example.com/detail.jpg"),
        url: URL? = URL(string: "https://example.com/detail"),
        pdfs: [String: URL] = [:]
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

