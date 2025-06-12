import SwiftUI

/// The main application entry point.
///
/// This app demonstrates API integration using The Composable Architecture (TCA).
/// It shows a profile view that retrieves and displays user information from an API.
@main
struct APICallsWithTCAApp: App {
    /// The body of the app, defining the main scene.
    var body: some Scene {
        WindowGroup {
            NavigationView {
                // Initialize the ProfileView with a store containing the ProfileFeature reducer
                ProfileView(store: .init(initialState: .init(), reducer: {
                    ProfileFeature()
                }))
            }
        }
    }
}
