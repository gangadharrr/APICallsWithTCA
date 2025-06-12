import Foundation

/// Represents the response structure from the API for a single user request.
///
/// This struct wraps the user data in the format returned by the API,
/// where user information is nested under a "data" key.
struct SingleUser: Decodable {
    /// The actual user data contained in the API response.
    var data: UserData
}

/// Represents a user's information retrieved from the API.
///
/// This struct contains all the personal information about a user
/// that is available from the API, including identification, contact details,
/// and profile image.
struct UserData: Decodable, Equatable {
    /// The unique identifier for the user.
    var id: Int
    
    /// The user's email address.
    var email: String
    
    /// The user's first name.
    var firstName: String
    
    /// The user's last name.
    var lastName: String
    
    /// The URL string for the user's avatar image.
    var avatar: String
    
    /// The user's full name, combining first and last name.
    ///
    /// This computed property concatenates the user's first and last name
    /// to create a complete display name.
    ///
    /// - Returns: A string containing the user's full name.
    var fullName: String {
        "\(firstName) \(lastName)"
    }

    /// The URL object for the user's avatar.
    ///
    /// This computed property converts the avatar string URL into a proper URL object
    /// for use with SwiftUI's AsyncImage and other URL-based APIs.
    ///
    /// - Returns: A URL object pointing to the user's avatar image.
    var avatarURL: URL {
        URL(string: avatar)!
    }

    /// Defines the mapping between JSON keys and struct properties.
    ///
    /// This enum handles the snake_case to camelCase conversion for properties
    /// that have different naming conventions between the API and Swift code.
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case avatar
        case firstName = "first_name"
        case lastName = "last_name"
    }
}

/// Represents possible errors that can occur during API operations.
///
/// This enum defines various error types that might be encountered when
/// interacting with the API, providing user-friendly error messages.
enum UserError: String, Equatable, Error {
    /// Error indicating server connectivity issues.
    case serverError = "Please check your internet connection  and try again!!!"
    
    /// Error indicating the requested user doesn't exist.
    case invalidUser = "The User doesn't exist, refresh and Try Again!!!"
    
    /// Error indicating an invalid URL was constructed.
    case invalidUrl =  "Internal Errror refresh and Try Again!!!"
    
    /// Error indicating an unexpected internal error occurred.
    case internalError =  "Something went wrong refresh and Try Again!!!"
}