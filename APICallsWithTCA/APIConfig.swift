import Foundation

/// APIConfig provides network communication functionality for the application
///
/// This enum encapsulates all API-related functionality, separating network concerns
/// from the rest of the application. Using an enum with static methods prevents
/// unnecessary instantiation while providing a namespace for API operations.
enum APIConfig {
    
    /// Retrieves user data from the Reqres.in API service
    ///
    /// This method demonstrates several key API handling patterns:
    /// 1. Async/await for clean asynchronous code without completion handlers
    /// 2. Result type to provide type-safe success/failure responses
    /// 3. Structured error handling with domain-specific error types
    /// 4. HTTP status code interpretation for appropriate error messages
    ///
    /// - Parameter id: The user ID to retrieve from the API
    /// - Returns: A Result containing either the successfully decoded UserData or a specific UserError
    /// - Throws: Only system-level errors from URLSession; business logic errors are returned in the Result
    static func getUser(id: Int) async throws -> Result<UserData, UserError> {
        // Using constants for API components enables easy modification if endpoints change
        // and improves readability of the URL construction
        let baseUrl = "https://reqres.in/api/"
        let users = "users/"
        
        // URL construction is validated to prevent runtime crashes
        // We return a specific error rather than throwing to maintain consistent error handling
        guard let userUrl = URL(string:"\(baseUrl)\(users)\(id)") else {
            return .failure(.invalidUrl)
        }
        
        do {
            let userRequest = URLRequest(url: userUrl)
            let (data, response) = try await URLSession.shared.data(for: userRequest)
            
            // HTTP status code handling provides specific error messages based on server response
            // This improves user experience by giving context-appropriate feedback
            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 200:
                    // Success case continues to data processing
                    break
                case 404:
                    // 404 specifically indicates the requested user doesn't exist
                    return .failure(.invalidUser)
                case 500..<599:
                    // Server errors are grouped to provide a consistent message
                    return .failure(.serverError)
                default:
                    // Any other unexpected status codes are handled gracefully
                    return .failure(.internalError)
                }
            }
            
            // JSON decoding is attempted with a specific error on failure
            // We use try? to handle decoding errors through our Result type rather than throwing
            guard let usersData = try? JSONDecoder().decode(SingleUser.self, from: data) else {
                return .failure(.internalError)
            }
            
            // We reset the URLSession to prevent potential memory leaks and state persistence issues
            // This is especially important in apps that make frequent API calls
            await URLSession.shared.reset()
            return .success(usersData.data)
        } catch {
            // Network-level errors (like no connectivity) are mapped to our domain-specific error type
            // This provides a consistent error handling approach throughout the app
            return .failure(.serverError)
        }
    }
}

