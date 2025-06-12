import SwiftUI
import ComposableArchitecture

/// `ProfileFeature` implements the core business logic for user profile management
/// using The Composable Architecture (TCA) pattern. It handles user navigation,
/// data fetching, and error management in a predictable state container.
struct ProfileFeature: Reducer {
    /// Represents the complete state of the profile feature
    struct State: Equatable {
        /// Current user ID being displayed, initialized to 1 as the starting point
        var id: Int = 1
        
        /// Stores error message when API calls fail, nil when no errors are present
        /// This is used to disable navigation controls when in error state
        var errorMessage: String?
        
        /// Holds the result of user data fetch operations, allowing for
        /// success/failure handling and proper UI state representation
        var response: Result<UserData, UserError>?
    }
    
    /// Defines all possible actions that can occur within the profile feature
    enum Action: Equatable {
        /// Triggered when the user requests the next profile
        case nextUserButtonTapped
        
        /// Triggered when the user requests the previous profile
        case previousUserButtonTapped
        
        /// Triggered when the user requests to reset to the first profile
        case refreshButtonTapped
        
        /// Internal action to initiate API data fetch
        case fetchData
        
        /// Action containing the result of an API fetch operation
        case fetchResponse(Result<UserData, UserError>)
    }

    /// The core reducer that handles state transitions based on actions
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .nextUserButtonTapped:
                // Business rule: Prevent navigation when in error state
                // This ensures users must resolve errors before continuing
                guard state.errorMessage == nil else {
                    return .none
                }

                // Increment user ID to navigate to next profile
                state.id += 1
                // Trigger data fetch for the new user ID
                return .send(.fetchData)

            case .previousUserButtonTapped:
                // Business rule: Prevent navigation when in error state
                // This ensures users must resolve errors before continuing
                guard state.errorMessage == nil else {
                    return .none
                }
                
                // Decrement user ID to navigate to previous profile
                state.id -= 1
                // Trigger data fetch for the new user ID
                return .send(.fetchData)
                
            case .refreshButtonTapped:
                // Reset to first user and refresh data
                // This serves as an error recovery mechanism and general reset
                state.id = 1
                return .send(.fetchData)
                
            case .fetchData:
                // Reset state before new fetch to show loading indicator
                // and clear any previous errors
                state.response = nil
                state.errorMessage = nil
                
                // Execute API call as a side effect using TCA's .run
                // Capturing current state to use in the async context
                return .run { [state = state] send in
                    let response = try await APIConfig.getUser(id: state.id)
                    // Send the API response back to the reducer
                    await send(.fetchResponse(response))
                }

            case .fetchResponse(.success(let userData)):
                // On successful API response, update state with user data
                state.response = .success(userData)
                return .none
                
            case .fetchResponse(.failure(let error)):
                // On API failure, update state with error information
                // This triggers error display in the UI
                state.response = .failure(error)
                state.errorMessage = error.rawValue
                return .none
            }
        }
    }
}

/// `ProfileView` is the main UI component for displaying user profiles
/// It demonstrates the TCA pattern for connecting state to UI components
/// and handling user interactions through actions
struct ProfileView: View {
    /// Store that connects the UI to the ProfileFeature reducer
    /// This provides type-safe access to state and action dispatch
    let store: StoreOf<ProfileFeature>
    
    var body: some View {
        // WithViewStore connects the SwiftUI view to the TCA Store
        // observe: {$0} means we're observing the entire state
        WithViewStore(self.store, observe: {$0}) { viewStore in
            // Main container for all UI elements
            VStack {
                // State-driven UI composition based on API response state
                // This pattern ensures UI always reflects current state
                switch viewStore.response {
                case .success(let user):
                    // Display profile when data is available
                    self.profileComponent(user)
                case .failure:
                    // Display error message when API call fails
                    // The error text comes directly from the state
                    Text(viewStore.errorMessage ?? "")
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                case nil:
                    // Show loading indicator when waiting for API response
                    // This appears during initial load and state transitions
                    ProgressView("Loading")
                        .progressViewStyle(.circular)
                        .tint(.accentColor)
                        .scaleEffect(1.3)
                }
            }
            .padding(.all)
            // Task modifier triggers data fetch when view appears
            // This ensures data is loaded automatically on view presentation
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
    /// - Parameter user: The user data to display
    /// - Returns: A view containing formatted user profile information
    ///
    /// This component is responsible for the visual presentation of user data
    /// using a consistent layout pattern with centered content.
    func profileComponent(_ user: UserData) -> some View {
        VStack {
            Spacer()

            // Profile header - establishes context for the view
            Text("Profile")
                .font(.title)
                .bold()

            // Avatar display with loading placeholder
            // AsyncImage handles remote image loading with loading state
            AsyncImage(url: user.avatarURL, scale: 0.5) { image in 
                image
                    .scaledToFit()
                    .clipShape(Circle()) // Circular crop for profile aesthetic
            } placeholder: {
                // Show progress indicator while image loads
                ProgressView().frame(width:250, height: 250)
            }

            // User metadata displayed in consistent format
            Text("User Id: \(user.id)")
                .foregroundColor(.gray)

            Text(user.fullName)
                .font(.title2)
                .bold()

            // Interactive email link using system mail integration
            Link(user.email, destination: URL(string: "mailto://\(user.email)")!)

            Spacer()
        }
    }

    /// Creates the navigation controls for the profile view
    /// - Parameter viewStore: The view store for dispatching actions
    /// - Returns: Toolbar content with navigation buttons
    ///
    /// This function creates a consistent navigation pattern with:
    /// - Previous button on the left
    /// - Refresh button in the center
    /// - Next button on the right
    @ToolbarContentBuilder
    func profileControls(
        _ viewStore: ViewStoreOf<ProfileFeature>
    ) -> some ToolbarContent {
        // Previous user navigation button
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                // Dispatch action to ProfileFeature reducer
                viewStore.send(.previousUserButtonTapped)
            } label: {
                Image(systemName: "arrow.left")
                Text("Previous")
            }
            // Disable navigation when in error state
            // This enforces the error recovery flow
            .disabled(viewStore.errorMessage != nil)
        }

        // Refresh button - always enabled as an error recovery mechanism
        ToolbarItem(placement: .status) {
            Button {
                // Dispatch refresh action to reset to first user
                viewStore.send(.refreshButtonTapped)
            } label: {
                Text("Refresh")
                Image(systemName: "arrow.clockwise")
            }
        }

        // Next user navigation button
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                // Dispatch action to ProfileFeature reducer
                viewStore.send(.nextUserButtonTapped)
            } label: {
                Text("Next")
                Image(systemName: "arrow.right")
            }
            // Disable navigation when in error state
            // This enforces the error recovery flow
            .disabled(viewStore.errorMessage != nil)
        }
    }
}

#Preview {
    ProfileView(store: Store(initialState: .init(), reducer: {
        ProfileFeature()
    }))
}
