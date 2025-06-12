import SwiftUI

/// The main application entry point that sets up the app structure and initial view.
///
/// This App implementation:
/// - Configures the root view hierarchy
/// - Sets up the TCA store for the ProfileFeature
/// - Wraps the ProfileView in a NavigationView for proper navigation
///
/// The app follows The Composable Architecture (TCA) pattern, where:
/// - State is managed through reducers
/// - UI components observe state through stores
/// - Actions flow unidirectionally through the system
///
/// # App Structure
/// ```
/// NavigationView
/// └── ProfileView (connected to ProfileFeature)
/// ```
@main
struct APICallsWithTCAApp: App {
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
