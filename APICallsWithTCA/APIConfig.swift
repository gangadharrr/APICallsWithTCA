import Foundation

/// Provides configuration and methods for API interactions.
/// This enum contains static methods for making API requests to external services.
enum APIConfig {
    
    /// Fetches user data from the remote API based on the provided user ID.
    ///
    /// This function makes an asynchronous network request to retrieve user information
    /// from the reqres.in API service. It handles various error scenarios and returns
    /// appropriate error messages.
    ///
    /// - Parameter id: The unique identifier of the user to fetch.
    /// - Returns: A Result containing either the successfully retrieved `UserData` or a `UserError`.
    /// - Throws: May throw network-related errors during the API call.
    ///
    /// - Example:
    /// ```swift
    /// do {
    ///     let result = try await APIConfig.getUser(id: 1)
    ///     switch result {
    ///     case .success(let userData):
    ///         // Process the user data
    ///     case .failure(let error):
    ///         // Handle the error
    ///     }
    /// } catch {
    ///     // Handle unexpected errors
    /// }
    /// ```
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