import SwiftUI
import ComposableArchitecture

/// A reducer that manages the state and actions for the profile feature.
///
/// This reducer handles loading user profiles, navigating between users,
/// and managing error states using The Composable Architecture pattern.
struct ProfileFeature: Reducer {
    /// Represents the state of the profile feature.
    ///
    /// Contains the current user ID, any error messages, and the API response.
    struct State: Equatable {
        /// The ID of the currently displayed user.
        var id: Int = 1
        
        /// Error message to display if an API request fails.
        var errorMessage: String?
        
        /// The result of the API request, containing either user data or an error.
        var response: Result<UserData, UserError>?
    }
    
    /// Defines the actions that can be performed in the profile feature.
    enum Action: Equatable {
        /// Action to navigate to the next user.
        case nextUserButtonTapped
        
        /// Action to navigate to the previous user.
        case previousUserButtonTapped
        
        /// Action to reset and refresh the current user data.
        case refreshButtonTapped
        
        /// Action to initiate a data fetch from the API.
        case fetchData
        
        /// Action containing the response from the API.
        /// - Parameter Result: Contains either the user data or an error.
        case fetchResponse(Result<UserData, UserError>)
    }

    /// The body of the reducer that handles state transitions based on actions.
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

/// The main view for displaying user profiles.
///
/// This view handles the presentation of user data, loading states, and error messages.
/// It also provides navigation controls to move between different user profiles.
struct ProfileView: View {
    /// The store that manages the state and actions for this view.
    let store: StoreOf<ProfileFeature>
    
    /// The body of the view that defines its appearance and behavior.
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
    
    /// Creates the profile component that displays user information.
    ///
    /// - Parameter user: The user data to display.
    /// - Returns: A view containing the user's profile information.
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

    /// Creates the toolbar controls for navigating between profiles.
    ///
    /// - Parameter viewStore: The view store that manages the state and actions.
    /// - Returns: Toolbar content containing navigation and refresh controls.
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