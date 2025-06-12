import SwiftUI
import ComposableArchitecture

struct ProfileFeature: Reducer {
    // Injected controller dependency
    private let userController: UserController
    
    init(userController: UserController) {
        self.userController = userController
    }
    
    struct State: Equatable {
        var id: Int = 1
        var errorMessage: String?
        var response: Result<UserData, UserError>?
    }
    
    enum Action: Equatable {
        case nextUserButtonTapped
        case previousUserButtonTapped
        case refreshButtonTapped
        case fetchData
        case fetchResponse(Result<UserData, UserError>)
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .nextUserButtonTapped:
                guard state.errorMessage == nil else {
                    return .none
                }

                // Use controller to calculate next user ID
                state.id = userController.getNextUserId(currentId: state.id)
                return .send(.fetchData)

            case .previousUserButtonTapped:
                guard state.errorMessage == nil else {
                    return .none
                }
                
                // Use controller to calculate previous user ID
                state.id = userController.getPreviousUserId(currentId: state.id)
                return .send(.fetchData)
                
            case .refreshButtonTapped:
                // Use controller to reset to initial user
                state.id = userController.getInitialUserId()
                return .send(.fetchData)
                
            case .fetchData:
                state.response = nil
                state.errorMessage = nil
                
                // Delegate data fetching to the controller
                return .run { [state = state] send in
                    let response = await userController.fetchUser(id: state.id)
                    await send(.fetchResponse(response))
                }

            case .fetchResponse(.success(let userData)):
                state.response = .success(userData)
                return .none
                
            case .fetchResponse(.failure(let error)):
                state.response = .failure(error)
                state.errorMessage = error.rawValue
                return .none
            }
        }
    }
}