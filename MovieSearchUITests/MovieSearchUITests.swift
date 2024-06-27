//
//  MovieSearchUITests.swift
//  MovieSearchUITests
//
//  Created by Jing Yang on 2024-06-24.
//

import XCTest

class MovieSearchUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false

        let app = XCUIApplication()
        app.launch()
    }

    func testSuccessfulSearch() throws {
        let app = XCUIApplication()
        
        // Ensure the search field exists
        let searchField = app.searchFields["Search movies"]
        XCTAssertTrue(searchField.exists, "The search field does not exist.")
        
        // Enter a search term
        searchField.tap()
        searchField.typeText("Batman")
        
        // Perform the search
        app.keyboards.buttons["Search"].tap()
        
        // Wait for the results to load
        let firstResult = app.staticTexts["Batman Begins"]
        let exists = NSPredicate(format: "exists == true")
        
        expectation(for: exists, evaluatedWith: firstResult, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
        
        // Verify the results
        XCTAssertTrue(firstResult.exists, "The first search result does not exist.")
    }
}
