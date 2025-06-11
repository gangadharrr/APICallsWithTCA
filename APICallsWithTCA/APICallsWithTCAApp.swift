import SwiftUI

/// The main entry point for the API Calls With TCA application.
///
/// This app demonstrates API integration using The Composable Architecture pattern.
@main
struct APICallsWithTCAApp: App {
    /// The scene containing the app's user interface.
    ///
    /// - Returns: A scene containing the profile view wrapped in a navigation view.
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
