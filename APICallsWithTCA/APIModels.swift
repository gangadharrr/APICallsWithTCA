import Foundation

/// Container structure for a single user response from the API
/// 
/// This structure matches the JSON response format from the API,
/// which wraps the actual user data in a "data" field
struct SingleUser: Decodable {
    /// The user data contained within the API response
    var data: UserData
}

/// Represents user information retrieved from the API
///
/// This structure contains all the personal information about a user
/// that is available through the API, including identification, contact info,
/// and profile image.
struct UserData: Decodable, Equatable {
    /// The unique identifier for the user
    var id: Int
    
    /// The user's email address
    var email: String
    
    /// The user's first name
    var firstName: String
    
    /// The user's last name
    var lastName: String
    
    /// The URL string for the user's avatar image
    var avatar: String
    
    /// Computed property that combines first and last name
    ///
    /// - Returns: A string containing the user's full name
    var fullName: String {
        "\(firstName) \(lastName)"
    }

    /// Computed property that converts the avatar string to a URL
    ///
    /// - Returns: A URL object for the user's avatar image
    /// - Note: This force unwraps the URL creation, assuming the API always provides valid URLs
    var avatarURL: URL {
        URL(string: avatar)!
    }

    /// Coding keys for mapping JSON property names to Swift property names
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case avatar
        case firstName = "first_name"
        case lastName = "last_name"
    }
}

/// Error types that can occur during user data retrieval
///
/// This enum defines all possible error conditions that might occur
/// during API operations, with user-friendly error messages.
enum UserError: String, Equatable, Error {
    /// Error indicating network connectivity issues or server unavailability
    case serverError = "Please check your internet connection  and try again!!!"
    
    /// Error indicating the requested user ID doesn't exist
    case invalidUser = "The User doesn't exist, refresh and Try Again!!!"
    
    /// Error indicating a malformed URL was created
    case invalidUrl =  "Internal Errror refresh and Try Again!!!"
    
    /// General error for unexpected conditions or parsing failures
    case internalError =  "Something went wrong refresh and Try Again!!!"
}
