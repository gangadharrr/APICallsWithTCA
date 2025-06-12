import SwiftUI
import ComposableArchitecture

/// A reducer that manages the profile feature's state and behavior
///
/// This reducer handles all the logic related to user profile data fetching,
/// navigation between users, and error handling.
struct ProfileFeature: Reducer {
    /// State for the profile feature
    ///
    /// Contains all the data needed to render the profile view and track
    /// the current user being displayed.
    struct State: Equatable {
        /// The current user ID being displayed or requested
        var id: Int = 1
        
        /// Error message to display if an error occurs
        var errorMessage: String?
        
        /// The result of the API call, containing either user data or an error
        var response: Result<UserData, UserError>?
    }
    
    /// Actions that can be performed in the profile feature
    ///
    /// These actions represent all possible user interactions and
    /// state transitions in the profile feature.
    enum Action: Equatable {
        /// Action triggered when the next user button is tapped
        case nextUserButtonTapped
        
        /// Action triggered when the previous user button is tapped
        case previousUserButtonTapped
        
        /// Action triggered when the refresh button is tapped
        case refreshButtonTapped
        
        /// Action to initiate data fetching for the current user ID
        case fetchData
        
        /// Action containing the response from the API call
        case fetchResponse(Result<UserData, UserError>)
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .nextUserButtonTapped:
                /// Handles navigation to the next user
                ///
                /// Increments the user ID and triggers a data fetch if no error is present.
                /// - Side effect: Triggers a data fetch for the new user ID
                guard state.errorMessage == nil else {
                    return .none
                }

                state.id += 1
                return .send(.fetchData)

            case .previousUserButtonTapped:
                /// Handles navigation to the previous user
                ///
                /// Decrements the user ID and triggers a data fetch if no error is present.
                /// - Side effect: Triggers a data fetch for the new user ID
                guard state.errorMessage == nil else {
                    return .none
                }
                
                state.id -= 1
                return .send(.fetchData)
                
            case .refreshButtonTapped:
                /// Handles resetting to the first user and refreshing data
                ///
                /// Resets the user ID to 1 and triggers a data fetch.
                /// - Side effect: Triggers a data fetch for user ID 1
                state.id = 1
                return .send(.fetchData)
                
            case .fetchData:
                /// Initiates the API call to fetch user data
                ///
                /// Clears any previous response and error message, then performs
                /// an async API call to get the user data for the current ID.
                /// - Side effect: Makes an API call and dispatches the fetchResponse action
                state.response = nil
                state.errorMessage = nil
                return .run { [state = state] send in
                    let response = try await APIConfig.getUser(id: state.id)
                    await send(.fetchResponse(response))
                }

            case .fetchResponse(.success(let userData)):
                /// Handles successful API response
                ///
                /// Updates the state with the fetched user data.
                state.response = .success(userData)
                return .none
                
            case .fetchResponse(.failure(let error)):
                /// Handles API error response
                ///
                /// Updates the state with the error and sets the error message.
                state.response = .failure(error)
                state.errorMessage = error.rawValue
                return .none
            }
        }
    }
}

/// View for displaying user profile information
///
/// This view displays user profile data fetched from the API and
/// provides navigation controls to move between different user profiles.
struct ProfileView: View {
    /// The store that manages the profile feature's state and actions
    let store: StoreOf<ProfileFeature>
    
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
    
    /// Creates the profile information display component
    ///
    /// This function builds the UI component that displays the user's profile
    /// information, including avatar, name, ID, and email.
    ///
    /// - Parameter user: The user data to display in the profile
    /// - Returns: A view containing the formatted profile information
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

    /// Creates the toolbar controls for profile navigation
    ///
    /// This function builds the toolbar items that allow the user to navigate
    /// between profiles and refresh the current profile.
    ///
    /// - Parameter viewStore: The ViewStore to send actions to
    /// - Returns: Toolbar content containing navigation and refresh buttons
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
