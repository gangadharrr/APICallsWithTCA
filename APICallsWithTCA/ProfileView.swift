import SwiftUI
import ComposableArchitecture

/// ProfileFeature is the core reducer that manages the user profile functionality
/// within The Composable Architecture (TCA) pattern.
///
/// This reducer handles all state transitions and side effects related to user profile management:
/// - Fetching user data from the API
/// - Navigating between different user profiles
/// - Handling success and error states
/// - Managing the UI state based on API responses
///
/// # Usage
/// ```swift
/// let store = Store(initialState: ProfileFeature.State(), reducer: {
///     ProfileFeature()
/// })
/// 
/// let profileView = ProfileView(store: store)
/// ```
///
/// # TCA Architecture
/// As part of TCA, this reducer:
/// - Defines the domain-specific State and Action types
/// - Processes Actions to update State and perform side effects
/// - Uses the .run effect to perform asynchronous API calls
/// - Maintains a unidirectional data flow
struct ProfileFeature: Reducer {
    /// Represents the complete state of the profile feature.
    ///
    /// This state object contains:
    /// - The current user ID being displayed
    /// - Any error messages that need to be shown
    /// - The API response which may contain user data or an error
    ///
    /// The state is marked as `Equatable` to enable TCA's state diffing
    /// which optimizes UI updates.
    struct State: Equatable {
        /// The ID of the user profile currently being viewed
        var id: Int = 1
        
        /// Error message to display when API calls fail
        var errorMessage: String?
        
        /// The result of the API call, containing either user data or an error
        var response: Result<UserData, UserError>?
    }
    
    /// Defines all possible actions that can be performed within the profile feature.
    ///
    /// These actions represent:
    /// - User interactions (button taps)
    /// - Internal events (data fetching)
    /// - External events (API responses)
    ///
    /// Each action triggers a state update through the reducer.
    enum Action: Equatable {
        /// User tapped the Next button to view the next profile
        case nextUserButtonTapped
        
        /// User tapped the Previous button to view the previous profile
        case previousUserButtonTapped
        
        /// User tapped the Refresh button to reset and reload profiles
        case refreshButtonTapped
        
        /// Internal action to initiate data fetching from the API
        case fetchData
        
        /// Action containing the API response with user data or an error
        case fetchResponse(Result<UserData, UserError>)
    }

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

/// A SwiftUI view that displays user profile information and provides navigation controls.
///
/// ProfileView is responsible for:
/// - Displaying user profile data in a structured format
/// - Showing appropriate loading and error states
/// - Providing UI controls for navigating between profiles
/// - Initiating profile data fetching on appearance
///
/// # TCA Integration
/// This view connects to the ProfileFeature reducer through the TCA Store:
/// - It observes state changes using WithViewStore
/// - It dispatches actions to the store based on user interactions
/// - It renders different UI based on the current state
///
/// # View Components
/// - Profile information display (avatar, name, email)
/// - Navigation controls (next, previous, refresh)
/// - Loading indicator
/// - Error message display
///
/// # Usage
/// ```swift
/// ProfileView(store: Store(initialState: .init(), reducer: {
///     ProfileFeature()
/// }))
/// ```
struct ProfileView: View {
    /// The TCA store that connects this view to the ProfileFeature reducer
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
    
    /// Creates the profile information component that displays user details.
    ///
    /// This method encapsulates the UI for showing:
    /// - User's avatar image (loaded asynchronously)
    /// - User ID
    /// - Full name
    /// - Email address (as a tappable link)
    ///
    /// - Parameter user: The user data to display
    /// - Returns: A SwiftUI View containing the formatted profile information
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

    /// Creates the toolbar navigation controls for the profile view.
    ///
    /// This method builds a toolbar with:
    /// - Previous button (left side)
    /// - Refresh button (center)
    /// - Next button (right side)
    ///
    /// The buttons are automatically disabled when there's an error state.
    ///
    /// - Parameter viewStore: The view store that provides state and action dispatch
    /// - Returns: ToolbarContent with navigation controls
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
