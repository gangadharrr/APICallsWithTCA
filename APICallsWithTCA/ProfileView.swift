import SwiftUI
import ComposableArchitecture

/// A reducer that manages the state and actions for the user profile feature.
///
/// This reducer handles user navigation, data fetching, and error handling for the profile view.
/// It uses The Composable Architecture (TCA) pattern to manage state and side effects.
struct ProfileFeature: Reducer {
    /// The state for the profile feature.
    ///
    /// This struct contains all the data needed to render the profile view and
    /// track the current state of the user profile being displayed.
    struct State: Equatable {
        /// The current user ID being displayed or requested
        var id: Int = 1
        
        /// Optional error message to display when an error occurs
        var errorMessage: String?
        
        /// The result of the API call, containing either user data or an error
        var response: Result<UserData, UserError>?
    }
    
    /// The actions that can be performed in the profile feature.
    ///
    /// This enum defines all the possible actions that can be dispatched to modify
    /// the state or trigger side effects in the profile feature.
    enum Action: Equatable {
        /// Action to navigate to the next user
        case nextUserButtonTapped
        
        /// Action to navigate to the previous user
        case previousUserButtonTapped
        
        /// Action to reset to the first user and refresh data
        case refreshButtonTapped
        
        /// Action to initiate data fetching for the current user ID
        case fetchData
        
        /// Action that contains the result of a data fetch operation
        /// - Parameter Result: Contains either the fetched user data or an error
        case fetchResponse(Result<UserData, UserError>)
    }

    /// The implementation of the reducer logic.
    ///
    /// This handles how each action transforms the current state and what effects should be triggered.
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .nextUserButtonTapped:
                guard state.errorMessage == nil else {
                    return .none
                }

                state.id += 1
                return .send(.fetchData)

            case .previousUserButtonTapped:
                guard state.errorMessage == nil else {
                    return .none
                }
                
                state.id -= 1
                return .send(.fetchData)
                
            case .refreshButtonTapped:
                state.id = 1
                return .send(.fetchData)
                
            case .fetchData:
                state.response = nil
                state.errorMessage = nil
                return .run { [state = state] send in
                    let response = try await APIConfig.getUser(id: state.id)
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

/// The view that displays user profile information.
///
/// This view uses The Composable Architecture to manage its state and user interactions.
/// It displays user information, loading states, and error messages based on the current state.
struct ProfileView: View {
    /// The store that manages the state for this view
    let store: StoreOf<ProfileFeature>
    
    /// The body of the view that defines its appearance
    var body: some View {
        WithViewStore(self.store, observe: {$0}) { viewStore in
            VStack {
                switch viewStore.response {
                case .success(let user):
                    self.profileComponent(user)
                case .failure:
                    Text(viewStore.errorMessage ?? "")
                case nil:
                    ProgressView("Loading")
                        .progressViewStyle(.circular)
                        .tint(.accentColor)
                        .scaleEffect(1.3)
                }
            }
            .padding(.all)
            .task {
                viewStore.send(.fetchData)
            }
            .toolbar {
                self.profileControls(viewStore)
            }
        }
    }
    
    /// Creates the profile information component displaying user details.
    ///
    /// - Parameter user: The UserData object containing information to display
    /// - Returns: A view displaying the user's profile information
    func profileComponent(_ user: UserData) -> some View {
        VStack {
            Spacer()

            Text("Profile")
                .font(.title)
                .bold()

            AsyncImage(url: user.avatarURL,scale: 0.5){image in image.scaledToFit().clipShape(Circle())
                
            } placeholder: {
                ProgressView().frame(width:250,height: 250)
            }

            Text("User Id: \(user.id)")
                .foregroundColor(.gray)

            Text(user.fullName)
                .font(.title2)
                .bold()

            Link(user.email, destination: URL(string: "mailto://\(user.email)")!)

            Spacer()
        }
    }

    /// Creates the navigation controls for the profile view.
    ///
    /// - Parameter viewStore: The ViewStore to send actions to
    /// - Returns: Toolbar content with navigation buttons
    @ToolbarContentBuilder
    func profileControls(
        _ viewStore: ViewStoreOf<ProfileFeature>
    ) -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                viewStore.send(.previousUserButtonTapped)
            } label: {
                Image(systemName: "arrow.left")
                Text("Previous")
            }
            .disabled(viewStore.errorMessage != nil)
        }

        ToolbarItem(placement: .status) {
            Button {
                viewStore.send(.refreshButtonTapped)
            } label: {
                Text("Refresh")
                Image(systemName: "arrow.clockwise")
            }
        }

        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                viewStore.send(.nextUserButtonTapped)
            } label: {
                Text("Next")
                Image(systemName: "arrow.right")
            }
            .disabled(viewStore.errorMessage != nil)
        }
    }
}

#Preview {
    ProfileView(store: Store(initialState: .init(), reducer: {
        ProfileFeature()
    }))
}