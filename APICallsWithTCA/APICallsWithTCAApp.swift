import SwiftUI
import ComposableArchitecture

@main
struct APICallsWithTCAApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                // Use dependency container to create the ProfileView with injected dependencies
                ProfileView(store: .init(
                    initialState: .init(),
                    reducer: { DependencyContainer.shared.makeProfileFeature() }
                ))
            }
        }
    }
}