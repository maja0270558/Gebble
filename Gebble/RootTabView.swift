//
//  RootTabView.swift
//  MelodifyLyrics
//
//  Created by DjangoLin on 2023/10/19.
//

import ComposableArchitecture
import Popovers
import SwiftUI

struct AppFeature: Reducer {
    @Dependency(\.sharedState) var globalStateClient

    enum Tab: Equatable {
        case artists
        case workshop
        case account
    }

    struct State: Equatable {
        var loginPresent: Bool = false
        var artistsTab = ArtistsFeature.State()
        var workshopTab = WorkshopFeature.State()
        var accountTab = AccountFeature.State()

        var selectedTab: Tab = .artists
    }

    enum Action: Equatable {
        case artistsTab(ArtistsFeature.Action)
        case workshopTab(WorkshopFeature.Action)
        case accountTab(AccountFeature.Action)

        case selectedTabChanged(Tab)
        case task
        case loginViewPresent(Bool)
        case updateLoginViewPresent(Bool)
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.artistsTab, action: /Action.artistsTab) {
            ArtistsFeature()
        }

        Scope(state: \.workshopTab, action: /Action.workshopTab) {
            WorkshopFeature()
        }

        Reduce<State, Action> { state, action in
            switch action {
            case let .selectedTabChanged(tab):
                state.selectedTab = tab
                return .none
            case .artistsTab, .workshopTab:
                return .none

            // MARK: - Login View

            case .task:
                /// subscribe global state sync to `AppFeature.State` through `loginViewPresent`
                return subscribe(
                    to: globalStateClient.globalStore,
                    keyPath: \.loginViewPresent,
                    action: Action.loginViewPresent
                )
            case let .updateLoginViewPresent(value):
                /// update global state
                globalStateClient.update(
                    \.globalStore,
                    action: .loginViewPresent(value)
                )
                return .none
            case let .loginViewPresent(open):
                /// This state will open login view
                state.loginPresent = open
                return .none
            }
        }
    }
}

struct RootTabView: View {
    let store: StoreOf<AppFeature>
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            TabView(
                selection: viewStore.binding(get: { $0.selectedTab }, send: { .selectedTabChanged($0) })
            ) {
                Group {
                    ArtistsView(
                        store: self.store.scope(
                            state: \.artistsTab,
                            action: AppFeature.Action.artistsTab
                        )
                    )
                    .tabItem {
                        Image(systemName: "figure.socialdance")
                        Text("Artists")
                    }
                    .tag(AppFeature.Tab.artists)

                    WorkshopView(
                        store: self.store.scope(
                            state: \.workshopTab,
                            action: AppFeature.Action.workshopTab
                        )
                    )
                    .tabItem {
                        Image(systemName: "cup.and.saucer")
                        Text("Workshop")
                    }
                    .tag(AppFeature.Tab.workshop)

                    AccountView(
                        store: self.store.scope(
                            state: \.accountTab,
                            action: AppFeature.Action.accountTab
                        )
                    )
                    .tabItem {
                        Image(systemName: "person.circle")
                        Text("Account")
                    }
                    .tag(AppFeature.Tab.account)
                }
                .toolbarBackground(Color.base, for: .tabBar)
                .toolbarBackground(.visible, for: .tabBar)
                .toolbarColorScheme(.light, for: .tabBar)
                .tint(Color.black)
            }
            .popover(present: .init(get: {
                viewStore.loginPresent
            }, set: { value in
                viewStore.send(.updateLoginViewPresent(value))
            }),
            attributes: {
                $0.position = .relative(
                    popoverAnchors: [
                        .center,
                    ]
                )

                let animation = Animation.spring(
                    response: 0.6,
                    dampingFraction: 0.8,
                    blendDuration: 1
                )
                let transition = AnyTransition.move(edge: .bottom).combined(with: .opacity)

                $0.presentation.animation = animation
                $0.presentation.transition = transition
                $0.dismissal.mode = [.dragDown, .tapOutside]
            }) { /// here!
                HStack {
                    VStack {
                        Text(
                            """
                            To login use any email and "password" for the password. If your email contains the \
                            characters "2fa" you will be taken to a two-factor flow, and on that screen you can \
                            use "1234" for the code.
                            """
                        )

                        Section {
                            TextField("blob@pointfree.co", text: .constant("viewStore.$email"))
                                .autocapitalization(.none)
                                .keyboardType(.emailAddress)
                                .textContentType(.emailAddress)

                            SecureField("••••••••", text: .constant("viewStore.$password"))
                        }

                        Button {
                            // NB: SwiftUI will print errors to the console about "AttributeGraph: cycle detected" if
                            //     you disable a text field while it is focused. This hack will force all fields to
                            //     unfocus before we send the action to the view store.
                            // CF: https://stackoverflow.com/a/69653555
                            _ = UIApplication.shared.sendAction(
                                #selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil
                            )
//                            viewStore.send(.loginButtonTapped)
                        } label: {
                            HStack {
                                Text("Log in")
                            }
                        }
                    }
                    .padding()
                }
                .background(Color.base)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(radius: 10)
            }
            .task {
                await viewStore.send(.task).finish()
            }
        }
    }
}

#Preview {
    RootTabView(
        store: Store(
            initialState: AppFeature.State(),
            reducer: {
                AppFeature()
//                    .dependency(\.sharedState, .mock)
                    ._printChanges()
            }
        )
    )
}
