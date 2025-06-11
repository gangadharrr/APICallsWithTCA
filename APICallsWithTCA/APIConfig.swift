import Foundation

/// Configuration for API endpoints and network operations.
///
/// This enum contains static methods for making API requests to retrieve user data.
enum APIConfig {
    
    /// Fetches user data for a specific user ID from the API.
    ///
    /// This method constructs the appropriate URL for the user endpoint,
    /// makes an asynchronous network request, and handles various response scenarios.
    ///
    /// - Parameter id: The unique identifier of the user to fetch.
    /// - Returns: A Result containing either the successfully retrieved `UserData` or a `UserError`.
    /// - Throws: May throw system-level errors related to network operations.
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

