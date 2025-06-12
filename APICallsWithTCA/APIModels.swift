import Foundation

/// A container for user data in API responses.
///
/// This struct represents the top-level JSON structure returned by the API,
/// which contains the user data in a nested 'data' property.
struct SingleUser: Decodable {
    /// The user data contained in the API response.
    var data: UserData
}

/// Model representing user information from the API.
///
/// This struct contains all the personal information about a user
/// that is retrieved from the API, including identification, contact info,
/// and profile image.
struct UserData: Decodable, Equatable {
    // MARK: - Properties
    
    /// Unique identifier for the user.
    var id: Int
    
    /// Email address of the user.
    var email: String
    
    /// First name of the user.
    var firstName: String
    
    /// Last name of the user.
    var lastName: String
    
    /// URL string for the user's avatar image.
    var avatar: String
    
    // MARK: - Computed Properties
    
    /// The user's full name, combining first and last name.
    var fullName: String {
        "\(firstName) \(lastName)"
    }

    /// The URL object for the user's avatar image.
    ///
    /// - Note: This assumes the avatar string is always a valid URL.
    var avatarURL: URL {
        URL(string: avatar)!
    }

    // MARK: - Coding Keys
    
    /// Coding keys for mapping JSON property names to Swift property names.
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
/// This enum represents the various error conditions that can occur
/// when retrieving or processing user data from the API.
enum UserError: String, Equatable, Error {
    /// Error indicating a server connectivity issue.
    case serverError = "Please check your internet connection and try again!!!"
    
    /// Error indicating the requested user does not exist.
    case invalidUser = "The User doesn't exist, refresh and Try Again!!!"
    
    /// Error indicating a problem with the constructed URL.
    case invalidUrl = "Internal Error refresh and Try Again!!!"
    
    /// Error indicating an unexpected internal problem.
    case internalError = "Something went wrong refresh and Try Again!!!"
}
