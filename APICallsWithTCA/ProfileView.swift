import SwiftUI
import ComposableArchitecture

/// ProfileFeature implements the core business logic for the user profile screen
///
/// This reducer follows The Composable Architecture pattern to manage state transitions
/// and side effects in a predictable, testable way. The architecture separates:
/// - State: The single source of truth for the UI
/// - Actions: Events that can change state (user interactions or external events)
/// - Reducer: Pure function mapping (State, Action) -> (State, Effect)
///
/// This separation enables comprehensive testing and predictable state management.
struct ProfileFeature: Reducer {
    /// State represents all data needed to render the profile screen
    ///
    /// Using a single state object ensures consistency between UI and logic.
    /// The Equatable conformance enables TCA to optimize rendering.
    struct State: Equatable {
        /// Current user ID being displayed, starting with 1
        var id: Int = 1
        
        /// Error message to display when API requests fail
        /// This is nil during normal operation
        var errorMessage: String?
        
        /// API response containing either user data or an error
        /// This is nil during initial load or while fetching
        var response: Result<UserData, UserError>?
    }
    
    /// Actions represent all possible events that can change state
    ///
    /// By defining a closed set of actions, we ensure all state
    /// transitions are explicit and traceable.
    enum Action: Equatable {
        /// User tapped the next button to view the next profile
        case nextUserButtonTapped
        
        /// User tapped the previous button to view the previous profile
        case previousUserButtonTapped
        
        /// User tapped the refresh button to reset to the first profile
        case refreshButtonTapped
        
        /// Internal action to initiate data fetching
        case fetchData
        
        /// Internal action containing the API response
        case fetchResponse(Result<UserData, UserError>)
    }

    /// The reducer function that handles all state transitions
    ///
    /// This is the core of the TCA pattern, mapping each action to
    /// state changes and side effects.
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .nextUserButtonTapped:
                // Prevent navigation when in an error state
                // This improves UX by requiring error resolution before proceeding
                guard state.errorMessage == nil else {
                    return .none
                }

                // Increment the user ID and fetch the next profile
                state.id += 1
                return .send(.fetchData)

            case .previousUserButtonTapped:
                // Prevent navigation when in an error state
                guard state.errorMessage == nil else {
                    return .none
                }
                
                // Decrement the user ID and fetch the previous profile
                // Note: The API will return an error for ID < 1, which is handled
                // in the UI through the error state
                state.id -= 1
                return .send(.fetchData)
                
            case .refreshButtonTapped:
                // Reset to the first user and fetch data
                // This serves as both an initial load and a recovery mechanism
                state.id = 1
                return .send(.fetchData)
                
            case .fetchData:
                // Clear previous response and error state before fetching
                // This triggers the loading UI state
                state.response = nil
                state.errorMessage = nil
                
                // Perform the API request as a side effect
                // Using .run enables async/await with TCA
                return .run { [state = state] send in
                    let response = try await APIConfig.getUser(id: state.id)
                    await send(.fetchResponse(response))
                }

            case .fetchResponse(.success(let userData)):
                // Store successful response and clear error state
                state.response = .success(userData)
                return .none
                
            case .fetchResponse(.failure(let error)):
                // Store error response and display user-friendly message
                state.response = .failure(error)
                state.errorMessage = error.rawValue
                return .none
            }
        }
    }
}

/// ProfileView implements the user interface for the profile feature
///
/// This view uses SwiftUI's declarative syntax combined with TCA's store
/// to create a reactive UI that updates based on state changes.
///
/// The view is structured to handle three distinct states:
/// 1. Loading state (when response is nil)
/// 2. Success state (when response contains user data)
/// 3. Error state (when response contains an error)
struct ProfileView: View {
    /// The store connecting this view to the ProfileFeature reducer
    let store: StoreOf<ProfileFeature>
    
    var body: some View {
        // WithViewStore connects the SwiftUI view to the TCA store
        // This enables the view to observe state changes and send actions
        WithViewStore(self.store, observe: {$0}) { viewStore in
            VStack {
                // Display different UI based on the current response state
                switch viewStore.response {
                case .success(let user):
                    // Show the profile when data is available
                    self.profileComponent(user)
                case .failure:
                    // Show error message when request failed
                    Text(viewStore.errorMessage ?? "")
                case nil:
                    // Show loading indicator while fetching data
                    ProgressView("Loading")
                        .progressViewStyle(.circular)
                        .tint(.accentColor)
                        .scaleEffect(1.3)
                }
            }
            .padding(.all)
            // Fetch data when the view appears
            .task {
                viewStore.send(.fetchData)
            }
            // Add navigation controls to the toolbar
            .toolbar {
                self.profileControls(viewStore)
            }
        }
    }
    
    /// Creates the profile display component with user information
    ///
    /// This method is extracted to improve readability and maintainability.
    /// It encapsulates the UI for displaying user data.
    func profileComponent(_ user: UserData) -> some View {
        VStack {
            Spacer()

            Text("Profile")
                .font(.title)
                .bold()

            // Load and display the user avatar asynchronously
            // This prevents UI blocking while images download
            AsyncImage(url: user.avatarURL, scale: 0.5) { image in 
                image.scaledToFit().clipShape(Circle())
            } placeholder: {
                ProgressView().frame(width: 250, height: 250)
            }

            Text("User Id: \(user.id)")
                .foregroundColor(.gray)

            Text(user.fullName)
                .font(.title2)
                .bold()

            // Create a tappable email link
            Link(user.email, destination: URL(string: "mailto://\(user.email)")!)

            Spacer()
        }
    }

    /// Creates the toolbar controls for profile navigation
    ///
    /// This method encapsulates the toolbar UI creation,
    /// improving readability of the main view body.
    @ToolbarContentBuilder
    func profileControls(
        _ viewStore: ViewStoreOf<ProfileFeature>
    ) -> some ToolbarContent {
        // Previous user button (left side)
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                viewStore.send(.previousUserButtonTapped)
            } label: {
                Image(systemName: "arrow.left")
                Text("Previous")
            }
            // Disable navigation when in error state
            .disabled(viewStore.errorMessage != nil)
        }

        // Refresh button (center)
        ToolbarItem(placement: .status) {
            Button {
                viewStore.send(.refreshButtonTapped)
            } label: {
                Text("Refresh")
                Image(systemName: "arrow.clockwise")
            }
        }

        // Next user button (right side)
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                viewStore.send(.nextUserButtonTapped)
            } label: {
                Text("Next")
                Image(systemName: "arrow.right")
            }
            // Disable navigation when in error state
            .disabled(viewStore.errorMessage != nil)
        }
    }
}

/// SwiftUI preview provider for the ProfileView
///
/// This enables rapid UI iteration using Xcode's canvas preview.
#Preview {
    ProfileView(store: Store(initialState: .init(), reducer: {
        ProfileFeature()
    }))
}
