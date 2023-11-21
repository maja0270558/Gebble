//
//  RootTabView.swift
//  MelodifyLyrics
//
//  Created by DjangoLin on 2023/10/19.
//

import ComposableArchitecture
import SwiftUI

typealias PopoverValue = RootPopoverFeature.State?

struct LoginFeature: Reducer {
    struct State: Equatable {
        var userName: String = ""
        var password: String = ""
    }

    enum Action: Equatable {
        case signinButtonTaped
    }

    var body: some ReducerOf<Self> {
        Reduce<State, Action> { _, _ in
            .none
        }
    }
}

struct MessageFeature: Reducer {
    struct State: Equatable {
        var title: String = ""
    }

    enum Action: Equatable {
    }

    var body: some ReducerOf<Self> {
        Reduce<State, Action> { _, _ in
            .none
        }
    }
}

struct RootPopoverFeature: Reducer {
    enum State: Equatable {
        case login(LoginFeature.State)
        case message(MessageFeature.State)
    }

    enum Action: Equatable {
        case login(LoginFeature.Action)
        case message(MessageFeature.Action)

    }

    var body: some Reducer<State, Action> {
        Scope(state: /State.login, action: /Action.login) {
            LoginFeature()
        }
        Scope(state: /State.message, action: /Action.message) {
            MessageFeature()
        }
    }
}

struct AppFeature: Reducer {
    enum Tab: Equatable {
        case artists
        case workshop
        case home
        case account
    }

    @Dependency(\.popoverClient) var popover

    struct State: Equatable {
        @PresentationState var popover: RootPopoverFeature.State? = nil

        var artistsTab = ArtistsFeature.State()
        var workshopTab = WorkshopFeature.State()
        var selectedTab: Tab = .artists
    }

    enum Action: Equatable {
        case popover(PresentationAction<RootPopoverFeature.Action>)
        case artistsTab(ArtistsFeature.Action)
        case workshopTab(WorkshopFeature.Action)
        case selectedTabChanged(Tab)
        case popoverResponse(PopoverValue)
        case task
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
            case .popover(.dismiss):
                popover.setValue(nil)
                return .none
            case .task:
                return .run { send in
                    for await value in popover.values() {
                        await send(.popoverResponse(value))
                    }
                }
            case let .selectedTabChanged(tab):
                state.selectedTab = tab
                return .none
            case .artistsTab, .workshopTab:
                return .none
            case let .popoverResponse(response):
                state.popover = response
                return .none
            case .popover:
                return .none
            }
        }
        .ifLet(\.$popover, action: /Action.popover) {
            RootPopoverFeature()
        }
    }
}

struct RootTabView: View {
    let store: StoreOf<AppFeature>
    @Dependency(\.popoverClient) var popover

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
                    state: \.$popover,
                    action: { .popover($0) }
                ),
                state: /RootPopoverFeature.State.login,
                action: RootPopoverFeature.Action.login
            ) { _ in
                Text("placeholder").onTapGesture {
                    popover.setValue(nil)
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
                AppFeature()._printChanges()
            }
        )
    )
}
