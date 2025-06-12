import SwiftUI

/// Main application entry point
///
/// This is the main app structure that configures the app's window and
/// initializes the root view with its associated store.
@main
struct APICallsWithTCAApp: App {
    /// Defines the app's window and scene structure
    ///
    /// Creates a navigation view containing the profile view with its
    /// initialized store for state management.
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
