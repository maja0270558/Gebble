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

    struct State: Equatable {
        var artists: [ArtistList.ArtistListItem]
        var collectionState: CollectionLoadingState<[ArtistList.ArtistListItem]>
    }

    enum Action: Equatable {
        case artistCellTap(ArtistList.ArtistListItem)
        case loadArtists
        case searchArtists(String)
        case arrtistsResponse(TaskResult<[ArtistList.ArtistListItem]>)
    }

    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .artistCellTap:
            return .none
        case .loadArtists:
            return .run { send in

                await send(
                    .arrtistsResponse(
                        TaskResult {
                           let list =  try await artistsClient.fetchArtistList()
                            return list.results
                        }
                    )
                )
            }
        case .searchArtists:
            return .none
        case let .arrtistsResponse(.success(responese)):
            state.artists = responese
            return .none
        case let .arrtistsResponse(.failure(error)):
            print(error.localizedDescription)
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
//        .redacted(reason: .placeholder)
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

                        LazyVGrid(columns: gridItemLayout, content: {
                            ForEach(viewStore.state.artists, id: \.artistName) { artist in
                                ArtistListCell(artist: artist)
                            }

                        })
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

#Preview {
    ArtistsView(
        store: Store(
            initialState: ArtistsFeature.State(artists: [],
                                               collectionState: .loading(placeholder: [])),
            reducer: {
                ArtistsFeature()
            }
        )
    )
}
