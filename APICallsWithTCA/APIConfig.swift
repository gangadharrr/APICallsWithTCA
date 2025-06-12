import Foundation

// MARK: - Deprecated
// This class is deprecated and will be removed in future versions.
// Please use UserService instead.
enum APIConfig {
    static func getUser(id: Int) async throws -> Result<UserData, UserError> {
        // Forward to UserService for backward compatibility
        return try await UserService().getUser(id: id)
    }
}