///
/// APIConfig.swift
/// APICallsWithTCA
///
/// Created by Gangadhar C on 8/15/24.
/// Copyright © 2024. All rights reserved.
///
/// API configuration and network request handling for the application.
///

import Foundation

/// Configuration and methods for API communication.
///
/// This enum provides methods to interact with the API, handling
/// network requests, responses, and error conditions.
enum APIConfig {
    /// Fetches user data from the API for a specific user ID.
    ///
    /// This method constructs a URL request to the user endpoint,
    /// handles the network request asynchronously, and processes
    /// the response.
    ///
    /// - Parameter id: The unique identifier of the user to fetch.
    ///
    /// - Returns: A Result containing either the successfully fetched UserData
    ///   or a UserError describing what went wrong.
    ///
    /// - Throws: Network-related errors that may occur during the request.
    static func getUser(id: Int) async throws -> Result<UserData, UserError> {
        let baseUrl = "https://reqres.in/api/"
        let users = "users/"
        
        // Building the API URL
        guard let userUrl = URL(string:"\(baseUrl)\(users)\(id)") else {
            return .failure(.invalidUrl)
        }
        
        do {
            let userRequest = URLRequest(url: userUrl)
            let (data, response) = try await URLSession.shared.data(for: userRequest)
            
            // Handling error response with HTTP status code
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
            
            // Data decoding from JSON into object
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