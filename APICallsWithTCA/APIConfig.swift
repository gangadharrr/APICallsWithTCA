import Foundation

/// Provides API configuration and network request functionality.
///
/// This enum serves as a namespace for API-related functions and settings:
/// - Defines API endpoints and base URLs
/// - Implements network request methods
/// - Handles response parsing and error mapping
///
/// The implementation uses modern Swift concurrency (async/await) for network operations
/// and provides strongly-typed results using Swift's Result type.
///
/// # API Integration
/// This component connects to the reqres.in API service to fetch user data.
/// It handles various response scenarios including success, user not found,
/// server errors, and network failures.
///
/// # Usage
/// ```swift
/// do {
///     let result = try await APIConfig.getUser(id: 1)
///     switch result {
///     case .success(let userData):
///         // Handle successful user data
///     case .failure(let error):
///         // Handle error with appropriate message
///     }
/// } catch {
///     // Handle unexpected errors
/// }
/// ```
enum APIConfig {
    /// Fetches user data from the API by user ID.
    ///
    /// This method:
    /// 1. Constructs the API URL with the user ID
    /// 2. Performs the network request using URLSession
    /// 3. Handles HTTP status codes appropriately
    /// 4. Parses the JSON response into UserData
    /// 5. Returns a Result type with either the parsed data or an error
    ///
    /// - Parameter id: The ID of the user to fetch
    /// - Returns: A Result containing either UserData on success or UserError on failure
    /// - Throws: System-level errors from URLSession
    static func getUser(id: Int) async throws -> Result<UserData, UserError> {
        let baseUrl = "https://reqres.in/api/"
        let users = "users/"
        
        // Building the api url
        guard let userUrl = URL(string:"\(baseUrl)\(users)\(id)") else {
            return .failure(.invalidUrl)
        }
        
        do {
            let userRequest = URLRequest(url: userUrl)
            let (data, response) = try await URLSession.shared.data(for: userRequest)
            
            // Handling Error response with HTTP status code
            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 200:
                    break
                case 404:
                    return .failure(.invalidUser)
                case 500..<599:
                    return .failure(.serverError)
                default:
                    return .failure(.internalError)
                }
            }
            
            // Data decoding from json into object
            guard let usersData = try? JSONDecoder().decode(SingleUser.self, from: data) else {
                return .failure(.internalError)
            }
            
            // (Optional) Clearing cache and cookies from previous URLSession
            await URLSession.shared.reset()
            return .success(usersData.data)
        } catch {
            return .failure(.serverError)
        }
    }
}

