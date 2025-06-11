///
/// APICallsWithTCAApp.swift
/// APICallsWithTCA
///
/// Created by Gangadhar C on 8/15/24.
/// Copyright © 2024. All rights reserved.
///
/// Main entry point for the APICallsWithTCA application.
///

import SwiftUI

/// The main application structure.
///
/// This is the entry point of the application, responsible for setting up
/// the main view hierarchy and application state.
@main
struct APICallsWithTCAApp: App {
    /// The body of the application scene.
    ///
    /// Configures the main window group with a navigation view
    /// containing the ProfileView as the root view.
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ProfileView(store: .init(initialState: .init(), reducer: {
                    ProfileFeature()
                }))
            }
        }
    }
}