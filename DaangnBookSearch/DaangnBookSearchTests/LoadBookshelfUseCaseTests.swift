import XCTest

final class LoadBookshelfUseCaseTests: XCTestCase {
    func test_execute_loadsBooksAndUpdatesStore() async throws {
        let repository = MockBookshelfRepository()
        let expectedBooks = [
            BookSummary.fixture(title: "Combine Essentials", subtitle: "Reactive Programming", isbn13: "3333333333333"),
            BookSummary.fixture(title: "iOS Testing", subtitle: "Beyond Unit Tests", isbn13: "4444444444444")
        ]
        repository.loadResult = .success(expectedBooks)
        let store = BookshelfStore(initialBooks: [])
        let useCase = LoadBookshelfUseCase(bookshelfStore: store, repository: repository)

        try await useCase.execute()

        XCTAssertEqual(repository.loadCallCount, 1)
        let storedBooks = await store.currentBooks
        XCTAssertEqual(storedBooks, expectedBooks)
    }
}

