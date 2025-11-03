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
        let repository = MockBookRepository()
        let books = [
            BookSummary.stub(title: "Swift Concurrency", subtitle: "Modern Async Patterns", isbn13: "111", price: "$10"),
            BookSummary.stub(title: "iOS Unit Testing", subtitle: "XCTest in Practice", isbn13: "222", price: "$12")
        ]
        repository.searchResult = (items: books, total: 2, page: 1)
        let useCase = SearchBooksUseCase(repo: repository)

        let suiteName = "SearchViewModelTests.success"
        guard let userDefaults = UserDefaults(suiteName: suiteName) else {
            XCTFail("Failed to create UserDefaults suite")
            return
        }
        userDefaults.removePersistentDomain(forName: suiteName)
        defer { userDefaults.removePersistentDomain(forName: suiteName) }

        let bookshelfStore = BookshelfStore(userDefaults: userDefaults)
        let sut = SearchViewModel(searchBooksUseCase: useCase, bookshelfStore: bookshelfStore)

        let expectation = expectation(description: "Search results delivered")

        sut.setStateChangeHandler { state in
            if !state.isLoading, state.books == books {
                XCTAssertEqual(state.page, 1)
                XCTAssertEqual(state.total, 2)
                XCTAssertNil(state.errorMessage)
                expectation.fulfill()
            }
        }

        // when
        sut.send(SearchViewModel.Intent.updateQuery("Swift"))
        sut.send(SearchViewModel.Intent.search)

        // then
        await fulfillment(of: [expectation], timeout: 1.0)
        XCTAssertEqual(repository.searchCallCount, 1)
    }

    @MainActor
    func testSearchFailureSetsErrorMessage() async throws {
        // given
        let repository = MockBookRepository()
        repository.searchError = MockError.searchFailed
        let useCase = SearchBooksUseCase(repo: repository)

        let suiteName = "SearchViewModelTests.failure"
        guard let userDefaults = UserDefaults(suiteName: suiteName) else {
            XCTFail("Failed to create UserDefaults suite")
            return
        }
        userDefaults.removePersistentDomain(forName: suiteName)
        defer { userDefaults.removePersistentDomain(forName: suiteName) }

        let bookshelfStore = BookshelfStore(userDefaults: userDefaults)
        let sut = SearchViewModel(searchBooksUseCase: useCase, bookshelfStore: bookshelfStore)

        let expectation = expectation(description: "Error state delivered")

        sut.setStateChangeHandler { state in
            if !state.isLoading, let message = state.errorMessage {
                XCTAssertEqual(message, "검색 결과를 불러오지 못했습니다.")
                XCTAssertTrue(state.books.isEmpty)
                expectation.fulfill()
            }
        }

        // when
        sut.send(SearchViewModel.Intent.updateQuery("Swift"))
        sut.send(SearchViewModel.Intent.search)

        // then
        await fulfillment(of: [expectation], timeout: 1.0)
        XCTAssertEqual(repository.searchCallCount, 1)
    }

    @MainActor
    func testSearchWithEmptyQueryDoesNotTriggerNetworkCall() {
        // given
        let repository = MockBookRepository()
        let useCase = SearchBooksUseCase(repo: repository)

        let suiteName = "SearchViewModelTests.emptyQuery"
        guard let userDefaults = UserDefaults(suiteName: suiteName) else {
            XCTFail("Failed to create UserDefaults suite")
            return
        }
        userDefaults.removePersistentDomain(forName: suiteName)
        defer { userDefaults.removePersistentDomain(forName: suiteName) }

        let bookshelfStore = BookshelfStore(userDefaults: userDefaults)
        let sut = SearchViewModel(searchBooksUseCase: useCase, bookshelfStore: bookshelfStore)

        // when
        sut.send(SearchViewModel.Intent.search)

        // then
        XCTAssertEqual(repository.searchCallCount, 0)
    }
}

// MARK: - BookDetailViewModelTests

final class BookDetailViewModelTests: XCTestCase {

    @MainActor
    func testLoadSuccessUpdatesDetailState() async {
        // given
        let repository = MockBookRepository()
        let detail = BookDetail.stub(isbn13: "999")
        repository.detailResult = detail
        let useCase = FetchBookDetailUseCase(repo: repository)
        let sut = BookDetailViewModel(fetchBookDetailUseCase: useCase)

        let expectation = expectation(description: "Book detail loaded")

        sut.setStateChangeHandler { state in
            if !state.isLoading, let loadedDetail = state.detail, loadedDetail.isbn13 == detail.isbn13 {
                XCTAssertNil(state.errorMessage)
                expectation.fulfill()
            }
        }

        // when
        sut.send(BookDetailViewModel.Intent.setISBN("999"))
        sut.send(BookDetailViewModel.Intent.load)

        // then
        await fulfillment(of: [expectation], timeout: 1.0)
        XCTAssertEqual(repository.detailCallCount, 1)
    }

    @MainActor
    func testLoadFailureSetsErrorMessage() async {
        // given
        let repository = MockBookRepository()
        repository.detailError = MockError.detailFailed
        let useCase = FetchBookDetailUseCase(repo: repository)
        let sut = BookDetailViewModel(fetchBookDetailUseCase: useCase)

        let expectation = expectation(description: "Book detail failed")

        sut.setStateChangeHandler { state in
            if !state.isLoading, let message = state.errorMessage {
                XCTAssertEqual(message, "상세 정보를 불러오지 못했습니다.")
                XCTAssertNil(state.detail)
                expectation.fulfill()
            }
        }

        // when
        sut.send(BookDetailViewModel.Intent.setISBN("999"))
        sut.send(BookDetailViewModel.Intent.load)

        // then
        await fulfillment(of: [expectation], timeout: 1.0)
        XCTAssertEqual(repository.detailCallCount, 1)
    }

    func testLoadWithoutISBNDoesNotCallRepository() {
        // given
        let repository = MockBookRepository()
        let useCase = FetchBookDetailUseCase(repo: repository)
        let sut = BookDetailViewModel(fetchBookDetailUseCase: useCase)

        // when
        sut.send(BookDetailViewModel.Intent.load)

        // then
        XCTAssertEqual(repository.detailCallCount, 0)
    }
}

// MARK: - BookshelfViewModelTests

final class BookshelfViewModelTests: XCTestCase {

    @MainActor
    func testLoadIntentRefreshesStateFromStore() {
        // given
        let suiteName = "BookshelfViewModelTests.load"
        guard let userDefaults = UserDefaults(suiteName: suiteName) else {
            XCTFail("Failed to create UserDefaults suite")
            return
        }
        userDefaults.removePersistentDomain(forName: suiteName)
        defer { userDefaults.removePersistentDomain(forName: suiteName) }

        let store = BookshelfStore(userDefaults: userDefaults)
        let expectedBooks = [
            BookSummary.stub(title: "Clean Architecture", subtitle: "Robert C. Martin", isbn13: "101", price: "$30"),
            BookSummary.stub(title: "Refactoring", subtitle: "Martin Fowler", isbn13: "202", price: "$28")
        ]
        expectedBooks.reversed().forEach { _ = store.add($0) }

        let sut = BookshelfViewModel(bookshelfStore: store)
        let expectation = expectation(description: "Bookshelf state refreshed")

        sut.setStateChangeHandler { state in
            if state.books == expectedBooks {
                expectation.fulfill()
            }
        }

        // when
        sut.send(BookshelfViewModel.Intent.load)

        // then
        wait(for: [expectation], timeout: 0.5)
        XCTAssertEqual(store.currentBooks, expectedBooks)
    }

    @MainActor
    func testRemoveIntentUpdatesStoreAndState() {
        // given
        let suiteName = "BookshelfViewModelTests.remove"
        guard let userDefaults = UserDefaults(suiteName: suiteName) else {
            XCTFail("Failed to create UserDefaults suite")
            return
        }
        userDefaults.removePersistentDomain(forName: suiteName)
        defer { userDefaults.removePersistentDomain(forName: suiteName) }

        let store = BookshelfStore(userDefaults: userDefaults)
        let bookA = BookSummary.stub(title: "Test-Driven Development", subtitle: "Kent Beck", isbn13: "303", price: "$24")
        let bookB = BookSummary.stub(title: "The Pragmatic Programmer", subtitle: "Andy Hunt", isbn13: "404", price: "$26")
        [bookB, bookA].forEach { _ = store.add($0) }

        let sut = BookshelfViewModel(bookshelfStore: store)
        let expectation = expectation(description: "Bookshelf item removed")

        sut.setStateChangeHandler { state in
            if state.books == [bookB] {
                expectation.fulfill()
            }
        }

        // when
        sut.send(BookshelfViewModel.Intent.remove(bookA))

        // then
        wait(for: [expectation], timeout: 0.5)
        XCTAssertEqual(store.currentBooks, [bookB])
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

