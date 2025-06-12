import Foundation

/// Represents the top-level response structure from the API for a single user request.
///
/// This model wraps the actual user data in a `data` property, following
/// the structure of the reqres.in API response format.
///
/// # API Response Example
/// ```json
/// {
///   "data": {
///     "id": 1,
///     "email": "user@example.com",
///     "first_name": "John",
///     "last_name": "Doe",
///     "avatar": "https://example.com/avatar.jpg"
///   }
/// }
/// ```
///
/// # Usage
/// ```swift
/// let userData = try JSONDecoder().decode(SingleUser.self, from: apiData)
/// let user = userData.data // Access the actual UserData
/// ```
struct SingleUser: Decodable {
    var data: UserData
}

/// Represents the core user data model containing all user profile information.
///
/// This model contains:
/// - Basic user identification (ID)
/// - Contact information (email)
/// - Name information (first and last name)
/// - Avatar image URL
/// - Computed properties for convenience (fullName, avatarURL)
///
/// The model conforms to:
/// - `Decodable` for JSON parsing
/// - `Equatable` for comparison operations in TCA
///
/// # Usage
/// ```swift
/// // Accessing properties
/// let name = userData.fullName
/// let imageURL = userData.avatarURL
///
/// // Comparing user data
/// if userData1 == userData2 {
///     // Users are the same
/// }
/// ```
struct UserData: Decodable, Equatable {
    var id: Int
    var email: String
    var firstName: String
    var lastName: String
    var avatar: String
    
    /// Computed property that combines first and last name into a full name.
    ///
    /// - Returns: A string containing the user's full name
    var fullName: String {
        "\(firstName) \(lastName)"
    }

    /// Converts the avatar string URL into a proper URL object.
    ///
    /// - Returns: A URL object for the user's avatar image
    /// - Warning: This force unwraps the URL. The API contract guarantees valid URLs.
    var avatarURL: URL {
        URL(string: avatar)!
    }

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case avatar
        case firstName = "first_name"
        case lastName = "last_name"
    }
}

/// Represents all possible error cases that can occur during user data retrieval.
///
/// This enum:
/// - Provides human-readable error messages via raw string values
/// - Conforms to Error for use in Swift's error handling system
/// - Conforms to Equatable for comparison in TCA and testing
///
/// # Error Cases
/// - serverError: Connection issues or server-side problems
/// - invalidUser: The requested user doesn't exist
/// - invalidUrl: URL construction problems (internal error)
/// - internalError: Catch-all for unexpected errors
///
/// # Usage
/// ```swift
/// switch result {
/// case .success(let userData):
///     // Handle success
/// case .failure(let error):
///     // Display error.rawValue as message to user
/// }
/// ```
enum UserError: String, Equatable, Error {
    case serverError = "Please check your internet connection  and try again!!!"
    case invalidUser = "The User doesn't exist, refresh and Try Again!!!"
    case invalidUrl =  "Internal Errror refresh and Try Again!!!"
    case internalError =  "Something went wrong refresh and Try Again!!!"
}
