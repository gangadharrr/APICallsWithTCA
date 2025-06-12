//
//  APICallsWithTCATests.swift
//  APICallsWithTCATests
//
//  Created by Gangadhar C on 8/15/24.
//

import XCTest
import ComposableArchitecture
@testable import APICallsWithTCA

/// Tests for the APICallsWithTCA application.
///
/// This test suite verifies the functionality of the API integration and
/// the ProfileFeature reducer.
final class APICallsWithTCATests: XCTestCase {

    /// Set up test environment before each test.
    ///
    /// This method prepares the test environment by initializing any required
    /// resources or dependencies.
    override func setUpWithError() throws {
        // No special setup required yet
    }

    /// Clean up test environment after each test.
    ///
    /// This method releases any resources allocated during tests.
    override func tearDownWithError() throws {
        // No special teardown required yet
    }

    /// Tests that the ProfileFeature correctly handles the next user action.
    ///
    /// This test verifies that when the next user button is tapped, the state
    /// is updated correctly and a fetch data action is dispatched.
    func testProfileFeatureNextUserAction() throws {
        // Create a test store with the ProfileFeature reducer
        let store = TestStore(
            initialState: ProfileFeature.State(id: 1),
            reducer: { ProfileFeature() }
        )
        
        // Test that tapping the next user button increments the ID and triggers a fetch
        store.send(.nextUserButtonTapped) { state in
            state.id = 2
        }
        
        // Verify that fetchData action was sent
        store.receive(.fetchData) { state in
            state.response = nil
            state.errorMessage = nil
        }
    }

    /// Tests that the ProfileFeature correctly handles the previous user action.
    ///
    /// This test verifies that when the previous user button is tapped, the state
    /// is updated correctly and a fetch data action is dispatched.
    func testProfileFeaturePreviousUserAction() throws {
        // Create a test store with the ProfileFeature reducer
        let store = TestStore(
            initialState: ProfileFeature.State(id: 2),
            reducer: { ProfileFeature() }
        )
        
        // Test that tapping the previous user button decrements the ID and triggers a fetch
        store.send(.previousUserButtonTapped) { state in
            state.id = 1
        }
        
        // Verify that fetchData action was sent
        store.receive(.fetchData) { state in
            state.response = nil
            state.errorMessage = nil
        }
    }

    /// Tests that the ProfileFeature correctly handles the refresh action.
    ///
    /// This test verifies that when the refresh button is tapped, the state
    /// is reset to the first user and a fetch data action is dispatched.
    func testProfileFeatureRefreshAction() throws {
        // Create a test store with the ProfileFeature reducer
        let store = TestStore(
            initialState: ProfileFeature.State(id: 5),
            reducer: { ProfileFeature() }
        )
        
        // Test that tapping the refresh button resets to user ID 1 and triggers a fetch
        store.send(.refreshButtonTapped) { state in
            state.id = 1
        }
        
        // Verify that fetchData action was sent
        store.receive(.fetchData) { state in
            state.response = nil
            state.errorMessage = nil
        }
    }
}
