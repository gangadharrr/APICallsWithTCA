import SwiftUI

/// The main entry point for the APICallsWithTCA application.
///
/// This struct defines the app structure and initializes the main view hierarchy.
@main
struct APICallsWithTCAApp: App {
    /// The body of the app that defines its scene structure.
    ///
    /// This creates a navigation view containing the ProfileView as the root view.
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