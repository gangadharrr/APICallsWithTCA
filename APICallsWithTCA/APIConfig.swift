import Foundation

/// `APIConfig` provides centralized API access methods and configuration
/// for the application. It encapsulates network interaction details and
/// provides a clean interface for data fetching operations.
enum APIConfig {
    /// Fetches user data from the remote API by ID
    /// - Parameter id: The ID of the user to fetch
    /// - Returns: A Result type containing either the user data or an error
    ///
    /// This method implements a comprehensive error handling strategy:
    /// 1. URL validation - Ensures the URL is properly formed before making a request
    /// 2. Network error handling - Catches and maps network-level errors
    /// 3. HTTP status code handling - Maps different status codes to appropriate errors
    /// 4. JSON decoding error handling - Handles data parsing failures
    ///
    /// The function returns a Result type that allows the caller to handle
    /// both success and failure cases in a type-safe manner.
    static func getUser(id: Int) async throws -> Result<UserData, UserError> {
        // API endpoint configuration
        // Using reqres.in as a test API service
        let baseUrl = "https://reqres.in/api/"
        let users = "users/"
        
        // Building the API URL with the requested user ID
        // Returns early with error if URL is malformed
        guard let userUrl = URL(string:"\(baseUrl)\(users)\(id)") else {
            return .failure(.invalidUrl)
        }
        
        do {
            // Create and execute the network request
            let userRequest = URLRequest(url: userUrl)
            let (data, response) = try await URLSession.shared.data(for: userRequest)
            
            // HTTP status code validation with specific error mapping
            // This provides clear feedback about different error conditions
            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 200:
                    // Success case - continue to data processing
                    break
                case 404:
                    // User not found - typically happens with invalid IDs
                    return .failure(.invalidUser)
                case 500..<599:
                    // Server-side errors - infrastructure or backend issues
                    return .failure(.serverError)
                default:
                    // Any other unexpected status codes
                    return .failure(.internalError)
                }
            }
            
            // Data decoding from JSON into strongly-typed model objects
            // Using try? to catch decoding errors and return a typed error
            guard let usersData = try? JSONDecoder().decode(SingleUser.self, from: data) else {
                return .failure(.internalError)
            }
            
            // Clean up network resources to prevent memory leaks
            // This is especially important for long-running applications
            await URLSession.shared.reset()
            
            // Return successful result with parsed user data
            return .success(usersData.data)
        } catch {
            // Catch and map any network-level errors
            // This includes connectivity issues, timeouts, etc.
            return .failure(.serverError)
        }
    }
}

