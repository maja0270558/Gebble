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
    case home
    case account
}

struct AppFeature: Reducer {
    struct State: Equatable {
        var artistsTab = ArtistsFeature.State(artists: [],
                                              collectionState: .empty)
        var selectedTab: Tab = .artists
    }

    enum Action: Equatable {
        case artistsTab(ArtistsFeature.Action)
        case selectedTabChanged(Tab)
    }

    var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case let .selectedTabChanged(tab):
                state.selectedTab = tab
                return .none
            case .artistsTab:
                return .none
            }
        }

        Scope(state: \.artistsTab, action: /Action.artistsTab) {
            ArtistsFeature()
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

                    Text("Home")
                        .tabItem {
                            Image(systemName: "house")
                            Text("Home")
                        }

                    Text("Account")
                        .tabItem {
                            Image(systemName: "person.circle")
                            Text("Account")
                        }
                }
                .toolbarBackground(Color.base, for: .tabBar)
                .toolbarBackground(.visible, for: .tabBar)
                .toolbarColorScheme(.light, for: .tabBar)
            }
            .tint(Color.yellow)
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
