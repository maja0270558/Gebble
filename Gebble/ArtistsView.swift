//
//  ArtistsView.swift
//  Gebble
//
//  Created by DjangoLin on 2023/10/24.
//

import ComposableArchitecture
import Kingfisher
import Shimmer
import SwiftUI

struct ArtistsFeature: Reducer {
    @Dependency(\.artistsClient) var artistsClient
    @Dependency(\.collectionStateStreamMaker) var collectionStateMaker
    @Dependency(\.mainQueue) private var mainQueue

    private enum CancelID { case artistsRequest, searchRequest }
    
    struct State: Equatable {
        var loadedCollectionState: CollectionLoadingState<[ArtistList.ArtistListItem]> = .unload
        var searchCollectionState: CollectionLoadingState<[ArtistList.ArtistListItem]> = .unload
        var currentCollectionState: CollectionLoadingState<[ArtistList.ArtistListItem]> = .unload
        var searchQuery: String = ""
    }

    enum Action: Equatable {
        case artistCellTap(ArtistList.ArtistListItem)
        case loadArtists
        case refresh
        case searchArtists(String)
        case arrtistsStateResponse(CollectionLoadingState<[ArtistList.ArtistListItem]>)
        case searchArrtistsResponse(CollectionLoadingState<[ArtistList.ArtistListItem]>)
        case arrtistsListResponse(CollectionLoadingState<[ArtistList.ArtistListItem]>)
    }

    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .artistCellTap:
            return .none
        case .refresh:
            return state.searchQuery.isEmpty ? .send(.loadArtists) : .send(.searchArtists(state.searchQuery))
        case let .searchArtists(query):
            Task.cancel(id: CancelID.searchRequest)
            state.searchQuery = query
            
            /// load back prev state
            guard !query.isEmpty else {
                    return state.loadedCollectionState != .unload ? .send(.arrtistsStateResponse(state.loadedCollectionState)) : .send(.loadArtists)
            }
            
            return .run { [query = state.searchQuery] send in
                for await state in await collectionStateMaker.maker.asyncStreamState(placeholder: ArtistList.ArtistListItem.placeholder,
                                                                                     body: {
                                                                                         let list = try await artistsClient.searchArtists(query)
                                                                                         return list
                                                                                     })
                {
                    await send(.searchArrtistsResponse(state))
                }
            }
            .debounce(id: CancelID.searchRequest, for: 0.5, scheduler: mainQueue)
            .cancellable(id: CancelID.searchRequest, cancelInFlight: true)

        case .loadArtists:
            Task.cancel(id: CancelID.artistsRequest)
            return .run { send in
                for await state in await collectionStateMaker.maker.asyncStreamState(placeholder: ArtistList.ArtistListItem.placeholder,
                                                                                     body: {
                                                                                         let list = try await artistsClient.fetchArtistList()
                                                                                         return list.results
                                                                                     })
                {
                    await send(.arrtistsListResponse(state))
                }
            }
            .cancellable(id: CancelID.artistsRequest)
            
        case let .searchArrtistsResponse(response):
            state.searchCollectionState = response
            return .send(.arrtistsStateResponse(response))
            
        case let .arrtistsListResponse(response):
            state.loadedCollectionState = response
            return .send(.arrtistsStateResponse(response))
            
        case let .arrtistsStateResponse(response):
            state.currentCollectionState = response
            return .none
        }
    }
}

struct ArtistListCell: View {
    var artist: ArtistList.ArtistListItem
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            KFImage(URL(string: "\(artist.thumb)"))
                .placeholder {
                    Image(systemName: "person")
                        .resizable()
                        .redacted(reason: .placeholder)
                }
                .resizable()
                .aspectRatio(1, contentMode: .fill)
                .cornerRadius(10)

            HStack {
                Text("\(artist.artistName)")
                    .lineLimit(1)
                    .layoutPriority(1)
                Spacer()
                Text("\(artist.countryFlag())")
                    .lineLimit(1)
                    .layoutPriority(2)
            }
            .padding( 4)
            .frame(height: 20)
        }
        .background(Color.base)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.gray, lineWidth: 0.2)
        )
    }
}

extension View {
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder func `if`<Content: View>(_ condition: @autoclosure () -> Bool, transform: (Self) -> Content) -> some View {
        if condition() {
            transform(self)
        } else {
            self
        }
    }
}

struct ArtistsView: View {
    let store: StoreOf<ArtistsFeature>
    @State var isLoading: Bool = false
    @State var searchText = ""
    var gridItemLayout = [GridItem(.flexible(), spacing: 8),
                          GridItem(.flexible(), spacing: 8),
                          GridItem(.flexible())]

    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading) {
                        Divider()
                            .padding(.bottom)
                        Text("Explore artist")
                            .font(.headline)
                        Text("Some thing  blablabla.Some thing  blablabla.Some thing  blablabla.Some thing")

                        CollectionLoadingView(loadingState: viewStore.state.currentCollectionState) { items in
                            
                            LazyVGrid(columns: gridItemLayout) {
                                ForEach(items, id: \.artistName) { artist in
                                    ArtistListCell(artist: artist)
                                        .frame(height: 140)
                                }
                            }

                        } empty: {
                            Text("empty")
                        } error: { _ in
                            Text("error")
                        }
                    }
                }
                .navigationTitle("Artists")
                .padding()
                .background(Color.base)
                .refreshable {
                    viewStore.send(.refresh)
                }
            }
            .searchable(
                text: viewStore.binding(
                    get: \.searchQuery,
                    send: {
                        .searchArtists($0)
                    }
                ),
                prompt: "Search for artist"
            )
            .autocorrectionDisabled()
            .tint(Color.black)
            .onViewDidLoad {
                viewStore.send(.loadArtists)
            }
        }
    }
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
