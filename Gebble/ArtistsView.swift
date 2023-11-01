//
//  ArtistsView.swift
//  Gebble
//
//  Created by DjangoLin on 2023/10/24.
//

import ComposableArchitecture
import Kingfisher
import SwiftUI

struct ArtistsFeature: Reducer {
    @Dependency(\.artistsClient) var artistsClient
    @Dependency(\.collectionStateStreamMaker) var collectionStateMaker

    struct State: Equatable {
        var collectionState: CollectionLoadingState<[ArtistList.ArtistListItem]> = .empty
    }

    enum Action: Equatable {
        case artistCellTap(ArtistList.ArtistListItem)
        case loadArtists
        case searchArtists(String)
        case arrtistsStateResponse(CollectionLoadingState<[ArtistList.ArtistListItem]>)
    }

    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .artistCellTap:
            return .none
        case .loadArtists:
            return .run { send in
                for await state in await collectionStateMaker.maker.asyncStreamState(placeholder: ArtistList.ArtistListItem.placeholder,
                                                                                     body: {
                                                                                         let list = try await artistsClient.fetchArtistList()
                                                                                         return list.results
                                                                                     })
                {
                    await send(.arrtistsStateResponse(state))
                }
            }
        case .searchArtists:
            return .none
        case let .arrtistsStateResponse(response):
            state.collectionState = response
            return .none
        }
    }
}

struct ArtistListCell: View {
    @State var artist: ArtistList.ArtistListItem
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Spacer()
            KFImage.url(URL(string: "\(artist.thumb)"))
                .placeholder {
                    Image(systemName: "person")
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .frame(height: 100)
                }
                .loadDiskFileSynchronously()
                .cacheMemoryOnly()
                .fade(duration: 0.25)

            HStack {
                Text("\(artist.artistName)")
                    .lineLimit(1)
                    .layoutPriority(2)

                Spacer()
                    .layoutPriority(0)

                Text("\(artist.countryFlag())")
                    .lineLimit(1)
                    .layoutPriority(2)
            }
            .frame(height: 20)
        }
        .padding(7)
        .background(Color.base)
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(.gray, lineWidth: 0.2)
        )
    }
}

struct ArtistsView: View {
    let store: StoreOf<ArtistsFeature>

    @State var searchText = ""
    var gridItemLayout = [GridItem(.flexible()),
                          GridItem(.flexible()),
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

                        CollectionLoadingView(loadingState: viewStore.state.collectionState) { items in
                            // loaded
                            LazyVGrid(columns: gridItemLayout, content: {
                                ForEach(items, id: \.artistName) { artist in
                                    ArtistListCell(artist: artist)
                                }
                            })

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
            }
            .searchable(text: $searchText, prompt: "Search for artist")
            .tint(Color.black)
            .onAppear {
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
                ArtistsFeature()
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
