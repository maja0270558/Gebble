//
//  ArtistsView.swift
//  Gebble
//
//  Created by DjangoLin on 2023/10/24.
//

import ActivityIndicatorView
import ComposableArchitecture
import SwiftUI

struct ArtistsFeature: Reducer {
    @Dependency(\.artistsClient) var artistsClient
    @Dependency(\.collectionStateStreamMaker) var dataAsyncStream
    @Dependency(\.mainQueue) private var mainQueue

    private enum CancelID { case artistsRequest, searchRequest }

    typealias ArtistsResult = CollectionLoadingState<[ArtistList.ArtistListItem]>
    
    struct State: Equatable {
        @PresentationState var artistDetail: ArtistsDetailFeature.State?
        var currentCollectionState: ArtistsResult = .unload
        var search: GebbleSearchBarFeature.State = .init(queryString: "", isFocused: false)
        internal var lastSearchResult = ""
    }

    enum Action: Equatable {
        case search(GebbleSearchBarFeature.Action)
        case binding(BindingAction<State>)
        case artistDetail(PresentationAction<ArtistsDetailFeature.Action>)
        case clickArtist(String)
        case loadArtists
        case refresh
        case artistListResponse(ArtistsResult)
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.search, action: /Action.search) {
            GebbleSearchBarFeature()
        }

        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case let .clickArtist(name):
                print(name)
                state.artistDetail = ArtistsDetailFeature.State(fetchArtist: name.lowercased())
                return .none
            case let .artistDetail(status):
                switch status {
                case .presented(.closeButtonClick):
                    state.artistDetail = nil
                    return .none
                default:
                    return .none
                }
            case .refresh:
                return state.search.queryString.isEmpty ? .send(.loadArtists) : .send(.search(.search(state.search.queryString)))
            case .loadArtists:
                Task.cancel(id: CancelID.artistsRequest)

                return .run { send in
                    let stream = await dataAsyncStream.maker.asyncStreamState(placeholder: ArtistList.ArtistListItem.placeholder) {
                        let list = try await artistsClient.fetchArtistList()
                        return list.results
                    }

                    await foreachStream(stream: stream) { state in
                        await send(.artistListResponse(state))
                    }
                }
                .debounce(id: CancelID.artistsRequest, for: 0.5, scheduler: mainQueue)
                .cancellable(id: CancelID.artistsRequest)

            case let .search(.search(query)):
                guard query != state.lastSearchResult else { return .none }
                Task.cancel(id: CancelID.searchRequest)

                guard !query.isEmpty else {
                    return .send(.loadArtists)
                }

                return .run { [query = state.search.queryString] send in
                    let stream = await dataAsyncStream.maker.asyncStreamState(placeholder: ArtistList.ArtistListItem.placeholder) {
                        let list = try await artistsClient.searchArtists(query)
                        return list
                    }

                    await foreachStream(stream: stream) { state in
                        await send(.artistListResponse(state))
                    }
                }
                .debounce(id: CancelID.searchRequest, for: 0.5, scheduler: mainQueue)
                .cancellable(id: CancelID.searchRequest, cancelInFlight: true)

            case let .artistListResponse(response):
                state.currentCollectionState = response
                state.lastSearchResult = state.search.queryString
                return .none

            case .search(.onFilterClick):
                return .none
            case .search(.cleanQuery):
                return .send(.search(.search("")))
            default:
                return .none
            }
        }
        .ifLet(\.$artistDetail, action: /Action.artistDetail) {
            ArtistsDetailFeature()
        }
    }
}

struct ArtistsView: View {
    let store: StoreOf<ArtistsFeature>
    var gridItemLayout = [GridItem(.flexible(), spacing: 8),
                          GridItem(.flexible(), spacing: 8),
                          GridItem(.flexible())]

    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationBaseView {
                ScrollView {
                    VStack(alignment: .leading) {
                     

                        CollectionLoadingView(loadingState: viewStore.state.currentCollectionState) { items in
                            VStack {
                                Text("Explore artist")
                                    .font(.headline)
                                Text("Embark on a Creative Journey: Discovering the Diverse World of Artists")
                                LazyVGrid(columns: gridItemLayout) {
                                    ForEach(items, id: \.artistName) { artist in

                                        GebbleCell(image: artist.thumb,
                                                   title: artist.artistName,
                                                   flag: artist.country)
                                            .onTapGesture {
                                                viewStore.send(.clickArtist(artist.username))
                                            }
                                    }
                                }
                            }
                            

                        } empty: {
                            GebbleEmptyView(title: "So quient here....")
                        } error: { error in
                            GebbleErrorView(title: error.localizedDescription)
                        }
                        Spacer()
                    }
                    .offset(y: 60)
                    .padding()
                    .navigationTitle("Artists")
                    .navigationBarHidden(viewStore.search.isFocused)
                }
                .overlay(content: {
                    VStack {
                        GebbleSearchBar(store: self.store.scope(state: \.search,
                                                                action: { .search($0) }),
                                        prompt: "Search artist",
                                        filter: false)
                        Spacer()

                    }.padding()

                })
                .onTapGesture {
                    hideKeyboard()
                }
                .refreshable {
                    viewStore.send(.refresh)
                }
            }
            .autocorrectionDisabled()
            .tint(Color.black)
            .onViewDidLoad {
                viewStore.send(.loadArtists)
            }
            .fullScreenCover(
                store: self.store.scope(state: \.$artistDetail,
                                        action: { .artistDetail($0) }))
            { store in
                ArtistDetailView(store: store)
            }
        }
    }
}

#Preview("Fake data") {
    ArtistsView(
        store: Store(
            initialState: ArtistsFeature.State(),
            reducer: {
                ArtistsFeature()
                    .dependency(\.artistsClient, .fakeValue)
                    ._printChanges()
            }
        )
    )
}

#Preview("Happy path") {
    ArtistsView(
        store: Store(
            initialState: ArtistsFeature.State(),
            reducer: {
                ArtistsFeature()._printChanges()
            }
        )
    )
}

#Preview("Empty data") {
    ArtistsView(
        store: Store(
            initialState: ArtistsFeature.State(),
            reducer: {
                ArtistsFeature()
                    .dependency(\.artistsClient, .emptyValue)
            }
        )
    )
}

#Preview("Error happen") {
    ArtistsView(
        store: Store(
            initialState: ArtistsFeature.State(),
            reducer: {
                ArtistsFeature()
                    .dependency(\.artistsClient, .errorValue)
            }
        )
    )
}

#Preview("Placeholder") {
    ArtistsView(
        store: Store(
            initialState: ArtistsFeature.State(),
            reducer: {
                ArtistsFeature()
                    .dependency(\.artistsClient, .errorValue)
                    .dependency(\.collectionStateStreamMaker, .placeholderValue)
            }
        )
    )
}
