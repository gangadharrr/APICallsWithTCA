//
//  APICallsWithTCAUITests.swift
//  APICallsWithTCAUITests
//
//  Created by Gangadhar C on 8/15/24.
//

import XCTest

/// Test suite for UI testing of the APICallsWithTCA application.
///
/// This class contains UI tests that verify the functionality and appearance
/// of the application's user interface components and interactions.
final class APICallsWithTCAUITests: XCTestCase {

    /// Sets up the test environment before each UI test.
    ///
    /// This method is called before the invocation of each test method in the class.
    /// It configures the test environment and prepares for UI testing, including
    /// setting failure behavior and initial interface state.
    ///
    /// - Throws: Throws an error if setup fails
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it's important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    /// Tears down the test environment after each UI test.
    ///
    /// This method is called after the invocation of each test method in the class.
    /// Use this method to clean up resources or reset state after UI tests.
    ///
    /// - Throws: Throws an error if teardown fails
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    /// Example UI test case demonstrating how to write a UI test.
    ///
    /// This test launches the application and can be extended to verify specific
    /// UI elements and interactions. Replace this with meaningful UI tests that
    /// verify specific behaviors of your application's interface.
    ///
    /// - Throws: Throws an error if the test fails unexpectedly
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    /// Performance test that measures application launch time.
    ///
    /// This test measures how long it takes for the application to launch,
    /// which can be useful for monitoring performance regressions.
    ///
    /// - Throws: Throws an error if the test fails unexpectedly
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}