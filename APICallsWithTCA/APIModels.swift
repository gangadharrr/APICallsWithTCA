///
/// APIModels.swift
/// APICallsWithTCA
///
/// Created by Gangadhar C on 8/15/24.
/// Copyright © 2024. All rights reserved.
///
/// Models for API data structures and error handling in the application.
///

import Foundation

/// A container for a single user response from the API.
///
/// This struct wraps the user data returned by the API's single user endpoint.
struct SingleUser: Decodable {
    /// The user data contained in the response.
    var data: UserData
}

/// A user data structure returned from the API.
///
/// This structure represents a user in the system and contains all
/// relevant user information returned from the API.
///
/// - Note: The `fullName` and `avatarURL` properties are computed from other properties.
///
/// Example usage:
/// ```swift
/// let user = UserData(id: 1, email: "user@example.com", firstName: "John", lastName: "Doe", avatar: "https://example.com/avatar.jpg")
/// print(user.fullName) // Prints: "John Doe"
/// ```
struct UserData: Decodable, Equatable {
    /// The unique identifier for the user.
    var id: Int
    
    /// The user's email address.
    var email: String
    
    /// The user's first name.
    var firstName: String
    
    /// The user's last name.
    var lastName: String
    
    /// URL string for the user's avatar image.
    var avatar: String
    
    /// The user's full name, combining first and last name.
    ///
    /// - Returns: A string containing the user's full name.
    var fullName: String {
        "\(firstName) \(lastName)"
    }

    /// The URL for the user's avatar image.
    ///
    /// - Returns: A URL object constructed from the avatar string.
    var avatarURL: URL {
        URL(string: avatar)!
    }

    /// Coding keys for mapping API response fields to property names.
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case avatar
        case firstName = "first_name"
        case lastName = "last_name"
    }
}

/// Errors that can occur during user data operations.
///
/// This enumeration represents the possible error states that can occur
/// when fetching or processing user data from the API.
enum UserError: String, Equatable, Error {
    /// Server connection error, possibly due to network connectivity issues.
    case serverError = "Please check your internet connection  and try again!!!"
    
    /// The requested user does not exist in the system.
    case invalidUser = "The User doesn't exist, refresh and Try Again!!!"
    
    /// The URL for the API request was invalid.
    case invalidUrl =  "Internal Errror refresh and Try Again!!!"
    
    /// An unexpected internal error occurred.
    case internalError =  "Something went wrong refresh and Try Again!!!"
}