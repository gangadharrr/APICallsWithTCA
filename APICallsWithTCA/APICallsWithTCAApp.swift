import SwiftUI

/// `APICallsWithTCAApp` is the main application entry point
/// It demonstrates a complete implementation of The Composable Architecture (TCA)
/// pattern for managing state, side effects, and UI in a SwiftUI application.
///
/// The application architecture follows these key principles:
/// 1. Single source of truth for state (ProfileFeature.State)
/// 2. Unidirectional data flow (Actions → Reducer → State → View)
/// 3. Clear separation of concerns between UI and business logic
/// 4. Predictable state management with explicit state transitions
/// 5. Testable business logic isolated from UI components
@main
struct APICallsWithTCAApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                // Initialize the main view with a TCA store
                // The store connects the ProfileFeature reducer to the ProfileView
                ProfileView(store: .init(initialState: .init(), reducer: {
                    // The ProfileFeature reducer is the central point for all
                    // business logic and state transitions in the application
                    ProfileFeature()
                }))
            }
        }
    }
}
