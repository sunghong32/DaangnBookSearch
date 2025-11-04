import XCTest

final class SearchBooksUseCaseTests: XCTestCase {
    func test_execute_delegatesToRepositoryAndReturnsResult() async throws {
        let repository = MockBookRepository()
        let expectedBooks = [
            BookSummary.fixture(title: "SwiftUI Design", subtitle: "Practical Guide", isbn13: "1111111111111"),
            BookSummary.fixture(title: "Modern Concurrency", subtitle: "Async/Await", isbn13: "2222222222222")
        ]
        repository.searchResult = .success((items: expectedBooks, total: 240, page: 3))
        let useCase = SearchBooksUseCase(bookRepository: repository)

        let result = try await useCase.execute(query: "swift", page: 3)

        XCTAssertEqual(repository.receivedSearchCalls.count, 1)
        XCTAssertEqual(repository.receivedSearchCalls.first?.query, "swift")
        XCTAssertEqual(repository.receivedSearchCalls.first?.page, 3)
        XCTAssertEqual(result.items, expectedBooks)
        XCTAssertEqual(result.total, 240)
        XCTAssertEqual(result.page, 3)
    }
}

