//
//  RootTabView.swift
//  MelodifyLyrics
//
//  Created by DjangoLin on 2023/10/19.
//

import ComposableArchitecture
import SwiftUI

enum Tab {
    case artists
    case workshop
    case home
    case account
}

struct AppFeature: Reducer {
    struct State: Equatable {
        var artistsTab = ArtistsFeature.State()
        var workshopTab = WorkshopFeature.State()

        var selectedTab: Tab = .artists
    }

    enum Action: Equatable {
        case artistsTab(ArtistsFeature.Action)
        case workshopTab(WorkshopFeature.Action)

        case selectedTabChanged(Tab)
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
            }
        }
    }
}

struct RootTabView: View {
    let store: StoreOf<AppFeature>

    var body: some View {
        WithViewStore(self.store, observe: \.selectedTab) { viewStore in
            TabView(selection: viewStore.binding(send: AppFeature.Action.selectedTabChanged)) {
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
                    .tag(Tab.artists)

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
                    .tag(Tab.workshop)

                    Text("Home")
                        .tabItem {
                            Image(systemName: "house")
                            Text("Home")
                        }
                        .tag(Tab.home)

                    Text("Account")
                        .tabItem {
                            Image(systemName: "person.circle")
                            Text("Account")
                        }
                        .tag(Tab.account)
                }
                .toolbarBackground(Color.base, for: .tabBar)
                .toolbarBackground(.visible, for: .tabBar)
                .toolbarColorScheme(.light, for: .tabBar)
                .tint(Color.black)
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
            }
        )
    )
}
