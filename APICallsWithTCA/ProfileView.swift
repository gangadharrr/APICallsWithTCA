///
/// ProfileView.swift
/// APICallsWithTCA
///
/// Created by Gangadhar C on 8/15/24.
/// Copyright © 2024. All rights reserved.
///
/// Profile view implementation using The Composable Architecture.
///

import SwiftUI
import ComposableArchitecture

/// A reducer that manages profile state and actions.
///
/// This reducer handles fetching user data, navigating between users,
/// and managing the profile view state.
struct ProfileFeature: Reducer {
    /// The state for the profile feature.
    ///
    /// Contains the current user ID, error message if any,
    /// and the API response.
    struct State: Equatable {
        /// The ID of the current user being displayed.
        var id: Int = 1
        
        /// Error message to display if an error occurs.
        var errorMessage: String?
        
        /// The result of the API call, containing either user data or an error.
        var response: Result<UserData, UserError>?
    }
    
    /// Actions that can be performed on the profile feature.
    enum Action: Equatable {
        /// Triggered when the next user button is tapped.
        case nextUserButtonTapped
        
        /// Triggered when the previous user button is tapped.
        case previousUserButtonTapped
        
        /// Triggered when the refresh button is tapped.
        case refreshButtonTapped
        
        /// Initiates data fetching from the API.
        case fetchData
        
        /// Handles the response from the API call.
        case fetchResponse(Result<UserData, UserError>)
    }

    /// The reducer logic for the profile feature.
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
/// This view shows user details fetched from the API and provides
/// navigation controls to browse different user profiles.
struct ProfileView: View {
    /// The store that manages the profile feature state and actions.
    let store: StoreOf<ProfileFeature>
    
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
    
    /// Creates the profile information component.
    ///
    /// - Parameter user: The user data to display.
    /// - Returns: A view displaying the user's profile information.
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
    /// - Parameter viewStore: The view store for accessing state and sending actions.
    /// - Returns: Toolbar content with navigation controls.
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

/// Preview provider for ProfileView.
#Preview {
    ProfileView(store: Store(initialState: .init(), reducer: {
        ProfileFeature()
    }))
}