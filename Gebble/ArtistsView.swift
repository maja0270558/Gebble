//
//  ArtistsView.swift
//  Gebble
//
//  Created by DjangoLin on 2023/10/24.
//

import ComposableArchitecture
import SwiftUI

struct ArtistsFeature: Reducer {
    struct State: Equatable {
        var artists: [ArtistList.ArtistListItem]
    }
    enum Action: Equatable {
        case artistCellTap(ArtistList.ArtistListItem)
        case loadArtists
        case searchArtists(String)
    }

    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .artistCellTap(_):
            return .none
        case .loadArtists:
            return .none
        case .searchArtists(_):
            return .none
        }
    }
}

struct ArtistListCell: View {
    @State var artist: ArtistList.ArtistListItem
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()
            Image(systemName: "person")
                .resizable()
                .aspectRatio(1, contentMode: .fit)

            HStack {
                Text("\(artist.artistName)")
                    .dynamicTypeSize(.small)
                    .lineLimit(1)
                    .frame(height: 20)
                Spacer()
                Image(systemName: "flag")
                    .aspectRatio(contentMode: .fit)
            }
        }
        .padding(5)
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
        }
    }
}

#Preview {
    ArtistsView(
        store: Store(
            initialState: ArtistsFeature.State(artists: [
                ArtistList.ArtistListItem(username: "django",
                                          artistName: "django rock",
                                          thumb: "",
                                          country: "tw"),
                
                ArtistList.ArtistListItem(username: "kookie",
                                          artistName: "django rock2",
                                          thumb: "",
                                          country: "tw")
            ]),
            reducer: {
                ArtistsFeature()
            }
        )
    )
}
