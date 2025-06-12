import Foundation
import ComposableArchitecture

// UserController handles the coordination between UI and business logic
class UserController {
    // Injected service dependency
    private let userService: UserServiceProtocol
    
    init(userService: UserServiceProtocol) {
        self.userService = userService
    }
    
    // Controller method to fetch user data
    func fetchUser(id: Int) async -> Result<UserData, UserError> {
        do {
            // Delegate the business logic to the service
            return try await userService.getUser(id: id)
        } catch {
            // Handle any unexpected errors
            return .failure(.serverError)
        }
    }
    
    // Controller method to calculate next user ID
    func getNextUserId(currentId: Int) -> Int {
        return currentId + 1
    }
    
    // Controller method to calculate previous user ID
    func getPreviousUserId(currentId: Int) -> Int {
        return max(1, currentId - 1)
    }
    
    // Controller method to reset to initial user
    func getInitialUserId() -> Int {
        return 1
    }
}