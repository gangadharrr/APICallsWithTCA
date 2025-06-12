import Foundation

/// A model representing the response structure from the API for a single user request.
///
/// This struct is designed to decode the outer JSON structure from the Reqres.in API,
/// which contains the user data nested within a "data" field.
struct SingleUser: Decodable {
    /// The actual user data contained within the API response
    var data: UserData
}

/// A model representing the core user data received from the API.
///
/// This struct contains all the essential user information including personal details
/// and avatar image URL. It also provides computed properties for convenience.
struct UserData: Decodable, Equatable {
    /// The unique identifier for the user
    var id: Int
    
    /// The email address of the user
    var email: String
    
    /// The first name of the user
    var firstName: String
    
    /// The last name of the user
    var lastName: String
    
    /// The URL string for the user's avatar image
    var avatar: String
    
    /// A computed property that combines the first and last name
    ///
    /// - Returns: A string containing the user's full name
    var fullName: String {
        "\(firstName) \(lastName)"
    }

    /// A computed property that converts the avatar string to a URL object
    ///
    /// - Returns: A URL object for the user's avatar image
    /// - Warning: This force-unwraps the URL which could cause crashes if the avatar string is invalid
    var avatarURL: URL {
        URL(string: avatar)!
    }

    /// Custom coding keys to map between Swift property names and JSON field names
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case avatar
        case firstName = "first_name"
        case lastName = "last_name"
    }
}

/// An enumeration of possible error cases that can occur during API operations.
///
/// Each case includes a user-friendly error message that can be displayed to the user.
enum UserError: String, Equatable, Error {
    /// Indicates a server connectivity issue
    case serverError = "Please check your internet connection and try again!!!"
    
    /// Indicates that the requested user ID doesn't exist
    case invalidUser = "The User doesn't exist, refresh and Try Again!!!"
    
    /// Indicates an issue with the URL formation
    case invalidUrl =  "Internal Error refresh and Try Again!!!"
    
    /// A general error for unexpected issues
    case internalError =  "Something went wrong refresh and Try Again!!!"
}