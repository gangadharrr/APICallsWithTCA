import SwiftUI

/// Main application entry point
///
/// This app structure follows SwiftUI's App protocol and serves as the root
/// of the application. It configures the main navigation structure and
/// initializes the TCA store for state management.
///
/// The application uses a NavigationView as its primary navigation container,
/// with the ProfileView as the root view. This architecture was chosen to:
/// 1. Provide a familiar iOS navigation experience
/// 2. Enable future expansion with additional screens
/// 3. Support the toolbar-based navigation controls in ProfileView
@main
struct APICallsWithTCAApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                // Initialize the ProfileView with a fresh TCA store
                // The store is configured with default initial state
                // and the ProfileFeature reducer for state management
                ProfileView(store: .init(initialState: .init(), reducer: {
                    ProfileFeature()
                }))
            }
        }
    }
}
