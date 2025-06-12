import Foundation

/// Represents the top-level response structure from the Reqres.in API for a single user request
///
/// The API returns user data nested within a 'data' field, which this struct captures.
/// This pattern follows the API's JSON structure, enabling direct decoding from the response.
struct SingleUser: Decodable {
    /// The actual user data contained within the API response
    var data: UserData
}

/// Represents core user information retrieved from the API
///
/// This model serves several important purposes:
/// 1. Provides a type-safe representation of user data
/// 2. Handles the conversion between snake_case API fields and camelCase Swift properties
/// 3. Offers computed properties for derived data to maintain a single source of truth
/// 4. Conforms to Equatable to enable comparison in state management and testing
struct UserData: Decodable, Equatable {
    /// Unique identifier for the user
    var id: Int
    
    /// User's email address
    var email: String
    
    /// User's first name
    var firstName: String
    
    /// User's last name
    var lastName: String
    
    /// URL string for the user's avatar image
    var avatar: String
    
    /// Computed property that combines first and last name
    /// This ensures consistent name formatting throughout the app
    var fullName: String {
        "\(firstName) \(lastName)"
    }

    /// Converts the avatar string to a URL for use with AsyncImage
    /// 
    /// Force unwrapping is used here because:
    /// 1. The API consistently provides valid URLs
    /// 2. The app's error handling would catch any issues before this point
    /// 3. If this assumption changes, we should modify this to return an optional URL
    var avatarURL: URL {
        URL(string: avatar)!
    }

    /// Maps the snake_case API field names to camelCase Swift property names
    ///
    /// This approach maintains Swift naming conventions while accommodating
    /// the API's JSON structure, making the code more maintainable.
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case avatar
        case firstName = "first_name"
        case lastName = "last_name"
    }
}

/// Represents all possible error states when interacting with the user API
///
/// This enum serves multiple purposes:
/// 1. Provides type-safe error handling with specific error cases
/// 2. Includes user-friendly error messages through raw string values
/// 3. Conforms to Error for system integration and Equatable for testing
///
/// Using a domain-specific error type rather than generic errors improves
/// code clarity and enables more precise error handling throughout the app.
enum UserError: String, Equatable, Error {
    /// Indicates network connectivity issues or server-side problems
    case serverError = "Please check your internet connection and try again!!!"
    
    /// Indicates that the requested user ID does not exist in the system
    case invalidUser = "The User doesn't exist, refresh and Try Again!!!"
    
    /// Indicates a problem with URL construction or validation
    case invalidUrl = "Internal Error refresh and Try Again!!!"
    
    /// Catch-all for unexpected errors like JSON parsing failures
    case internalError = "Something went wrong refresh and Try Again!!!"
}
