import XCTest

final class FetchBookDetailUseCaseTests: XCTestCase {
    func test_execute_returnsRepositoryDetail() async throws {
        let repository = MockBookRepository()
        let expectedDetail = BookDetail.fixture(isbn13: "9781234567890")
        repository.detailResult = .success(expectedDetail)
        let useCase = FetchBookDetailUseCase(bookRepository: repository)

        let detail = try await useCase.execute(isbn13: expectedDetail.isbn13)

        XCTAssertEqual(repository.receivedDetailISBNs, [expectedDetail.isbn13])
        XCTAssertEqual(detail, expectedDetail)
    }
}

