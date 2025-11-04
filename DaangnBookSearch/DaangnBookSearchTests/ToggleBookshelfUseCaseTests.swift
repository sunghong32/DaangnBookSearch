import XCTest

final class ToggleBookshelfUseCaseTests: XCTestCase {
    func test_execute_togglesFavoriteAndPersistsState() async throws {
        let repository = MockBookshelfRepository()
        let store = BookshelfStore(initialBooks: [])
        let useCase = ToggleBookshelfUseCase(bookshelfStore: store, repository: repository)
        let book = BookSummary.fixture(title: "Refactoring Swift", subtitle: "Maintainable Code", isbn13: "5555555555555")

        let added = try await useCase.execute(book: book)

        let booksAfterAdd = await store.currentBooks

        XCTAssertTrue(added)
        XCTAssertEqual(booksAfterAdd, [book])
        XCTAssertEqual(repository.saveCalls, [[book]])

        let removed = try await useCase.execute(book: book)

        let booksAfterRemove = await store.currentBooks

        XCTAssertFalse(removed)
        XCTAssertEqual(booksAfterRemove, [])
        XCTAssertEqual(repository.saveCalls, [[book], []])
    }
}

