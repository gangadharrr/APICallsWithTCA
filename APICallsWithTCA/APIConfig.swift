import Foundation

/// API configuration and network request handling.
///
/// This enum provides methods for making API requests to retrieve user data.
/// It handles URL construction, network requests, error handling, and response parsing.
enum APIConfig {
    
    // MARK: - API Constants
    
    /// Base URL for the API.
    private static let baseUrl = "https://reqres.in/api/"
    
    /// Users endpoint path.
    private static let usersEndpoint = "users/"
    
    // MARK: - API Methods
    
    /// Retrieves user data from the API by user ID.
    ///
    /// This method constructs the API URL, makes the network request,
    /// handles HTTP status codes, and parses the response data.
    ///
    /// - Parameter id: The ID of the user to retrieve.
    /// - Returns: A Result containing either the user data or an error.
    /// - Throws: Network-related errors from URLSession.
    static func getUser(id: Int) async throws -> Result<UserData, UserError> {
        // Construct the API URL
        guard let userUrl = URL(string: "\(baseUrl)\(usersEndpoint)\(id)") else {
            return .failure(.invalidUrl)
        }
        
        do {
            let userRequest = URLRequest(url: userUrl)
            let (data, response) = try await URLSession.shared.data(for: userRequest)
            
            // Handle HTTP status codes
            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 200:
                    // Success, continue processing
                    break
                case 404:
                    return .failure(.invalidUser)
                case 500..<599:
                    return .failure(.serverError)
                default:
                    return .failure(.internalError)
                }
            }
            
            // Parse JSON response into model objects
            guard let usersData = try? JSONDecoder().decode(SingleUser.self, from: data) else {
                return .failure(.internalError)
            }
            
            // Clean up session resources
            await URLSession.shared.reset()
            return .success(usersData.data)
        } catch {
            // Handle network errors
            return .failure(.serverError)
        }
    }
}

