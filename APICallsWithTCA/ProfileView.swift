import SwiftUI
import ComposableArchitecture

struct ProfileFeature: Reducer {
    struct State: Equatable, Sendable {
        var id: Int = 1
        var errorMessage: String?
        var response: Result<UserData, ApiError>?
    }
    
    enum Action: Equatable, Sendable {
        case nextUserButtonTapped
        case previousUserButtonTapped
        case refreshButtonTapped
        case fetchData
        case fetchResponse(Result<UserData, ApiError>)
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
                    do {
                        let response = try await ApiConfig.getUser(id: state.id)
                        await send(.fetchResponse(response))
                    } catch {
                        await send(.fetchResponse(.failure(.serverError)))
                    }
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

struct ProfileView: View {
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
            .toolbar {
                self.profileControls(viewStore)
            }
            .task {
                viewStore.send(.fetchData)
            }
        }
    }
    
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
