import Foundation
import ComposableArchitecture

// Simple dependency injection container
class DependencyContainer {
    // Singleton instance for app-wide access
    static let shared = DependencyContainer()
    
    // Lazy initialization of services
    lazy var userService: UserServiceProtocol = {
        return UserService()
    }()
    
    // Lazy initialization of controllers
    lazy var userController: UserController = {
        return UserController(userService: userService)
    }()
    
    // Method to create a ProfileFeature with dependencies injected
    func makeProfileFeature() -> ProfileFeature {
        return ProfileFeature(userController: userController)
    }
}