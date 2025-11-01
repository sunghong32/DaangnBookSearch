//
//  DaangnBookSearchUITests.swift
//  DaangnBookSearchUITests
//
//  Created by 민성홍 on 10/27/25.
//

import XCTest

final class DaangnBookSearchUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunchDisplaysSearchUI() {
        let app = XCUIApplication()
        app.launch()

        let searchTextField = app.textFields["책 제목, 저자명으로 검색"]
        XCTAssertTrue(searchTextField.waitForExistence(timeout: 2))

        let searchButton = app.buttons["검색"]
        XCTAssertTrue(searchButton.exists)

        XCTAssertTrue(app.staticTexts["책 검색"].exists)
    }
}
