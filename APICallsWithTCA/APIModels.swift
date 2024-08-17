import Foundation

struct SingleUser:Decodable{
    var data: UserData
}

struct UserData: Decodable, Equatable {
    var id:Int
    var email:String
    var firstName:String
    var lastName:String
    var avatar:String
    
    var fullName:String{
        "\(firstName) \(lastName)"
    }
    var avatarURL:URL{
        URL(string: avatar)!
    }
    enum CodingKeys:String,CodingKey{
        case id
        case email
        case avatar
        case firstName="first_name"
        case lastName="last_name"
    }
}

enum UserError: String, Equatable, Error {
    case serverError = "Please check your internet connection  and try again!!!"
    case invalidUser = "The User doesn't exist, refresh and Try Again!!!"
    case invalidUrl =  "Internal Errror refresh and Try Again!!!"
    case internalError =  "Something went wrong refresh and Try Again!!!"
}

