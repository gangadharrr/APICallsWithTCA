import Foundation

/// Configuration for API calls and network operations
enum APIConfig {
    /// Fetches user data from the remote API based on the provided user ID
    ///
    /// This function performs an asynchronous network request to retrieve user information
    /// from the reqres.in API service. It handles various error scenarios including
    /// invalid URLs, server errors, and data parsing issues.
    ///
    /// - Parameter id: The unique identifier of the user to fetch
    /// - Returns: A Result containing either the successfully fetched UserData or a UserError
    /// - Throws: May throw network-related errors during the data fetch operation
    ///
    /// - Note: The function clears the URLSession cache after completing the request
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

