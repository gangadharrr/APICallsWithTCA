import Foundation

/// `SingleUser` represents the top-level response structure from the reqres.in API
/// The API returns user data nested within a "data" field, which this model captures
struct SingleUser: Decodable {
    /// The nested user data from the API response
    var data: UserData
}

/// `UserData` represents the core user information model in the application
/// It serves as the primary data entity for displaying user profiles
/// and implements Equatable to support state comparison in TCA
struct UserData: Decodable, Equatable {
    /// Unique identifier for the user
    var id: Int
    
    /// User's email address, used for contact information and mailto links
    var email: String
    
    /// User's first name from the API
    var firstName: String
    
    /// User's last name from the API
    var lastName: String
    
    /// URL string for the user's avatar image
    var avatar: String
    
    /// Computed property that combines first and last name for display purposes
    /// This simplifies UI code by providing a ready-to-use full name
    var fullName: String {
        "\(firstName) \(lastName)"
    }

    /// Computed property that converts the avatar string to a URL object
    /// This makes it directly usable with SwiftUI's AsyncImage component
    var avatarURL: URL {
        URL(string: avatar)!
    }

    /// Maps the snake_case JSON field names from the API to 
    /// the camelCase property names used in Swift
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case avatar
        case firstName = "first_name"
        case lastName = "last_name"
    }
}

/// `UserError` defines all possible error states for user data operations
/// Each case includes a user-friendly message that can be displayed directly in the UI
/// 
/// This enum implements:
/// - String: For raw values containing user-facing error messages
/// - Equatable: For comparison in TCA state management
/// - Error: For use in Swift error handling mechanisms
enum UserError: String, Equatable, Error {
    /// Network connectivity or server availability issues
    /// Suggests checking internet connection as a recovery action
    case serverError = "Please check your internet connection and try again!!!"
    
    /// User ID doesn't exist in the database or API
    /// Typically occurs when navigating past the available user range
    case invalidUser = "The User doesn't exist, refresh and Try Again!!!"
    
    /// Malformed URL or API endpoint configuration issue
    /// This is generally a development-time error rather than runtime
    case invalidUrl = "Internal Error refresh and Try Again!!!"
    
    /// Catch-all for unexpected errors, including JSON parsing failures
    /// Provides a generic recovery suggestion to the user
    case internalError = "Something went wrong refresh and Try Again!!!"
}
