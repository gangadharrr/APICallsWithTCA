import Foundation

enum ApiConfig {
    static func getUser(id: Int) async throws -> Result<UserData, ApiError> {
        let baseUrl = "https://reqres.in/api/"
        let users = "users/"
        guard let userUrl = URL(string:"\(baseUrl)\(users)\(id)") else {
            return .failure(.invalidUrl)
        }
        
        let userRequest = URLRequest(url: userUrl)
        let (data, response) = try await URLSession.shared.data(for: userRequest)
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
        
        let allUsersData = try? JSONDecoder().decode(SingleUser.self, from: data)
        guard let usersData = allUsersData else {
            return .failure(.internalError)
        }

        await URLSession.shared.reset()
        return .success(usersData.data)
    }
}

enum ApiError: String, Equatable, Error {
    case serverError = "Please check your internet connection  and try again!!!"
    case invalidUser = "The User doesn't exist, refresh and Try Again!!!"
    case invalidUrl =  "Internal Errror refresh and Try Again!!!"
    case internalError =  "Something went wrong refresh and Try Again!!!"
}
