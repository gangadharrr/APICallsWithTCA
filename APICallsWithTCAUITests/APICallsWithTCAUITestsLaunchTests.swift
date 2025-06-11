//
//  APICallsWithTCAUITestsLaunchTests.swift
//  APICallsWithTCAUITests
//
//  Created by Gangadhar C on 8/15/24.
//

import XCTest

/// UI test suite specifically for testing application launch.
///
/// This test case captures screenshots of the launch process and verifies the launch behavior.
final class APICallsWithTCAUITestsLaunchTests: XCTestCase {

    /// Indicates whether the test should run for each target application UI configuration.
    ///
    /// - Returns: `true` to run the test for each configuration, `false` to run once.
    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    /// Set up method called before each launch test.
    ///
    /// - Throws: Throws an error if setup fails.
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    /// Tests the application launch process and captures a screenshot.
    ///
    /// This test launches the application and captures a screenshot of the launch screen.
    /// - Throws: Throws an error if the test fails.
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
