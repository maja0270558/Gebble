//
//  RootTabView.swift
//  MelodifyLyrics
//
//  Created by DjangoLin on 2023/10/19.
//

import ComposableArchitecture
import SwiftUI

struct AppFeature: Reducer {
    @Dependency(\.sharedState) var globalStateClient
    
    enum Tab: Equatable {
        case artists
        case workshop
        case home
        case account
    }

    struct State: Equatable {
        @PresentationState var loginView: LoginFeature.State?

        var artistsTab = ArtistsFeature.State()
        var workshopTab = WorkshopFeature.State()
        var selectedTab: Tab = .artists
    }

    enum Action: Equatable {
        
        case artistsTab(ArtistsFeature.Action)
        case workshopTab(WorkshopFeature.Action)
        case selectedTabChanged(Tab)
        case task
        case loginViewPresent(Bool)
        case loginView(PresentationAction<LoginFeature.Action>)
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
                return subscribe(
                    to: globalStateClient.globalStore,
                    keyPath: \.loginViewPresent,
                    action: Action.loginViewPresent
                )
            case let .loginViewPresent(open):
                state.loginView = open ? LoginFeature.State() : nil
                return .none
            case let .loginView(present):
                globalStateClient.update(
                    \.globalStore,
                     action: .loginViewPresent(present != .dismiss)
                )
                return .none
            }
        }
        .ifLet(\.$loginView, action: /Action.loginView) {
            LoginFeature()
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

                    Text("Home")
                        .tabItem {
                            Image(systemName: "house")
                            Text("Home")
                        }
                        .tag(AppFeature.Tab.home)

                    Text("Account")
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
            .sheet(
                store: self.store.scope(
                    state: \.$loginView,
                    action: { .loginView($0) }
                )
            ) { _ in
                Text("Login").onTapGesture {
                }
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
