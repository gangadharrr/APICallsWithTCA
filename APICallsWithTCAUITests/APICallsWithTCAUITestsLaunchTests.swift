//
//  APICallsWithTCAUITestsLaunchTests.swift
//  APICallsWithTCAUITests
//
//  Created by Gangadhar C on 8/15/24.
//

import XCTest

/// Test suite for launch-specific UI testing of the APICallsWithTCA application.
///
/// This class contains UI tests specifically focused on the launch experience of the application.
/// It captures screenshots of the launch process and verifies launch behavior across different
/// configurations.
final class APICallsWithTCAUITestsLaunchTests: XCTestCase {

    /// Indicates whether the test should run for each possible target application UI configuration.
    ///
    /// When set to true, the test will run once for each combination of supported device, orientation,
    /// and system appearance (light/dark mode).
    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    /// Sets up the test environment before each launch test.
    ///
    /// This method is called before the invocation of each test method in the class.
    /// It configures the test environment to fail immediately when errors occur.
    ///
    /// - Throws: Throws an error if setup fails
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    /// Tests the application launch process and captures a screenshot of the launch screen.
    ///
    /// This test launches the application and captures a screenshot of the initial launch screen.
    /// The screenshot is attached to the test results for visual verification and documentation.
    ///
    /// - Throws: Throws an error if the test fails unexpectedly
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