import SwiftUI
import ComposableArchitecture

/// Feature that manages user profile data and navigation.
///
/// This reducer handles fetching user profiles, navigating between users,
/// and managing the associated UI state.
struct ProfileFeature: Reducer {
    // MARK: - State
    
    /// State for the Profile feature.
    ///
    /// Contains the current user ID, any error messages, and the API response.
    struct State: Equatable {
        /// The ID of the current user being displayed.
        var id: Int = 1
        
        /// Error message to display, if any.
        var errorMessage: String?
        
        /// The result of the API call, containing either user data or an error.
        var response: Result<UserData, UserError>?
    }
    
    // MARK: - Actions
    
    /// Actions that can occur in the Profile feature.
    ///
    /// Represents all user interactions and effects that can happen in this feature.
    enum Action: Equatable {
        /// User tapped the button to navigate to the next user.
        case nextUserButtonTapped
        
        /// User tapped the button to navigate to the previous user.
        case previousUserButtonTapped
        
        /// User tapped the refresh button to reset to the first user.
        case refreshButtonTapped
        
        /// Internal action to initiate data fetching.
        case fetchData
        
        /// Internal action representing the result of a data fetch operation.
        case fetchResponse(Result<UserData, UserError>)
    }

    // MARK: - Reducer
    
    /// Reducer for the Profile feature.
    ///
    /// Handles all the business logic for navigating between users and fetching user data.
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .nextUserButtonTapped:
                // Only proceed if there's no error
                guard state.errorMessage == nil else {
                    return .none
                }

                // Increment the user ID and fetch data for the new user
                state.id += 1
                return .send(.fetchData)

            case .previousUserButtonTapped:
                // Only proceed if there's no error
                guard state.errorMessage == nil else {
                    return .none
                }
                
                // Decrement the user ID and fetch data for the new user
                state.id -= 1
                return .send(.fetchData)
                
            case .refreshButtonTapped:
                // Reset to the first user and fetch their data
                state.id = 1
                return .send(.fetchData)
                
            case .fetchData:
                // Clear previous response and error state
                state.response = nil
                state.errorMessage = nil
                
                // Execute the API call
                return .run { [state = state] send in
                    let response = try await APIConfig.getUser(id: state.id)
                    await send(.fetchResponse(response))
                }

            case .fetchResponse(.success(let userData)):
                // Store the successful response
                state.response = .success(userData)
                return .none
                
            case .fetchResponse(.failure(let error)):
                // Store the error response and update error message
                state.response = .failure(error)
                state.errorMessage = error.rawValue
                return .none
            }
        }
    }
}

/// A view that displays user profile information.
///
/// This view shows user details retrieved from the API, including name, email,
/// and profile picture. It also provides navigation controls to browse between users.
struct ProfileView: View {
    /// The store that powers this view.
    let store: StoreOf<ProfileFeature>
    
    // MARK: - Body
    
    /// The body of the view.
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
    
    // MARK: - View Components
    
    /// Returns a view that displays the user profile information.
    ///
    /// - Parameter user: The user data to display.
    /// - Returns: A view displaying the user's profile information.
    func profileComponent(_ user: UserData) -> some View {
        VStack {
            Spacer()

            Text("Profile")
                .font(.title)
                .bold()

            AsyncImage(url: user.avatarURL, scale: 0.5) { image in 
                image
                    .scaledToFit()
                    .clipShape(Circle())
            } placeholder: {
                ProgressView().frame(width: 250, height: 250)
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

    /// Returns toolbar items for profile navigation.
    ///
    /// - Parameter viewStore: The view store containing the current state.
    /// - Returns: Toolbar content with navigation controls.
    @ToolbarContentBuilder
    func profileControls(
        _ viewStore: ViewStoreOf<ProfileFeature>
    ) -> some ToolbarContent {
        // Previous user button
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                viewStore.send(.previousUserButtonTapped)
            } label: {
                Image(systemName: "arrow.left")
                Text("Previous")
            }
            .disabled(viewStore.errorMessage != nil)
        }

        // Refresh button
        ToolbarItem(placement: .status) {
            Button {
                viewStore.send(.refreshButtonTapped)
            } label: {
                Text("Refresh")
                Image(systemName: "arrow.clockwise")
            }
        }

        // Next user button
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

/// Preview provider for ProfileView.
#Preview {
    ProfileView(store: Store(initialState: .init(), reducer: {
        ProfileFeature()
    }))
}
