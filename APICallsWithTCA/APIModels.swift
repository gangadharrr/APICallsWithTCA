import Foundation

/// A model representing the response from the single user API endpoint.
/// Contains the user data wrapped in a `data` property.
struct SingleUser: Decodable {
    /// The user data returned by the API.
    var data: UserData
}

/// A model representing user data returned from the API.
/// Contains personal information like name, email, and avatar URL.
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
    
    /// The concatenated full name of the user.
    ///
    /// Combines the first and last name with a space in between.
    /// - Returns: A string containing the user's full name.
    var fullName: String {
        "\(firstName) \(lastName)"
    }

    /// The URL object created from the avatar string.
    ///
    /// - Returns: A URL object for the user's avatar image.
    /// - Note: This property force unwraps the URL creation. The API is expected to always provide valid URLs.
    var avatarURL: URL {
        URL(string: avatar)!
    }

    /// Coding keys for mapping JSON keys to struct properties.
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case avatar
        case firstName = "first_name"
        case lastName = "last_name"
    }
}

/// Error types that can occur during user data retrieval operations.
///
/// Each case includes a user-friendly error message as its raw value.
enum UserError: String, Equatable, Error {
    /// Occurs when there's a network connectivity issue or the server is unavailable.
    case serverError = "Please check your internet connection  and try again!!!"
    
    /// Occurs when attempting to retrieve a user that doesn't exist in the system.
    case invalidUser = "The User doesn't exist, refresh and Try Again!!!"
    
    /// Occurs when the API URL is malformed or cannot be constructed properly.
    case invalidUrl =  "Internal Errror refresh and Try Again!!!"
    
    /// A general error case for unexpected issues during API operations.
    case internalError =  "Something went wrong refresh and Try Again!!!"
}
