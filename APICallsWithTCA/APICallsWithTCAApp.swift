import SwiftUI

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
