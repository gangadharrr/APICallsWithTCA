import SwiftUI

/// The main entry point for the APICallsWithTCA application.
///
/// This struct conforms to the App protocol and sets up the initial scene
/// and view hierarchy for the application.
@main
struct APICallsWithTCAApp: App {
    /// The body of the application that defines its scene structure.
    ///
    /// This property creates the main window group containing the ProfileView
    /// wrapped in a NavigationView.
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