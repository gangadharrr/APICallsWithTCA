import SwiftUI
import ComposableArchitecture

/// A reducer that manages the state and actions for the user profile feature.
///
/// This reducer handles loading user data from the API, navigation between users,
/// and error handling for the profile view.
struct ProfileFeature: Reducer {
    /// State for the profile feature.
    ///
    /// Contains the current user ID, any error messages, and the API response data.
    struct State: Equatable {
        /// The ID of the current user being displayed.
        /// Defaults to 1 for the initial user.
        var id: Int = 1
        
        /// Error message to display when an API request fails.
        /// `nil` when there is no error.
        var errorMessage: String?
        
        /// The result of the API request, containing either user data or an error.
        /// `nil` when no request has been made or a request is in progress.
        var response: Result<UserData, UserError>?
    }
    
    /// Actions that can be performed within the profile feature.
    enum Action: Equatable {
        /// Triggered when the user taps the "Next" button to view the next user.
        case nextUserButtonTapped
        
        /// Triggered when the user taps the "Previous" button to view the previous user.
        case previousUserButtonTapped
        
        /// Triggered when the user taps the "Refresh" button to reset and reload user data.
        case refreshButtonTapped
        
        /// Internal action to initiate fetching user data from the API.
        case fetchData
        
        /// Internal action containing the response from the API request.
        /// - Parameter Result: A Result containing either the user data or an error.
        case fetchResponse(Result<UserData, UserError>)
    }

    /// The body of the reducer that handles state changes based on actions.
    ///
    /// - Returns: A reducer that processes actions and updates state accordingly.
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

/// A view that displays user profile information.
///
/// This view uses The Composable Architecture to manage state and user interactions.
/// It displays user data fetched from the API and provides navigation controls to browse between users.
struct ProfileView: View {
    /// The store that manages the state and actions for this view.
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
    
    /// Creates a view that displays the user profile information.
    ///
    /// - Parameter user: The user data to display in the profile.
    /// - Returns: A view containing the formatted user profile.
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

    /// Creates the toolbar controls for navigating between users.
    ///
    /// - Parameter viewStore: The view store containing the current state and action dispatch capabilities.
    /// - Returns: Toolbar content with navigation buttons.
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
