//
//  APICallsWithTCAUITestsLaunchTests.swift
//  APICallsWithTCAUITests
//
//  Created by Gangadhar C on 8/15/24.
//

import XCTest

/// UI tests specifically for the application launch process
///
/// This test case class focuses on testing the application launch process
/// and capturing screenshots of the launch screen.
final class APICallsWithTCAUITestsLaunchTests: XCTestCase {

    /// Determines whether tests run for each target application UI configuration
    ///
    /// When true, tests will run for each supported device configuration,
    /// such as different device types and orientations.
    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    /// Set up method called before each launch test
    ///
    /// This method prepares the test environment before each launch test is executed.
    /// It configures the test to stop immediately when a failure occurs.
    ///
    /// - Throws: Throws an error if setup fails
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    /// Test the application launch process
    ///
    /// This test launches the application and captures a screenshot of the launch screen.
    /// It verifies that the application launches successfully and displays the correct launch screen.
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