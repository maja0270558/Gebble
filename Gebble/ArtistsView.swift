//
//  ArtistsView.swift
//  Gebble
//
//  Created by DjangoLin on 2023/10/24.
//

import ComposableArchitecture
import SwiftUI

struct ArtistsFeature: Reducer {
    struct State: Equatable {}
    enum Action: Equatable {}

    func reduce(into state: inout State, action: Action) -> Effect<Action> {}
}

struct ArtistListCell: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()
            Image(systemName: "person")
                .resizable()
                .aspectRatio(1, contentMode: .fit)

            HStack {
                Text("artistName")
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
        WithViewStore(self.store, observe: { $0 }) { _ in
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading) {
                        Divider()
                            .padding(.bottom)
                        Text("Explore artist")
                            .font(.headline)
                        Text("Some thing  blablabla.Some thing  blablabla.Some thing  blablabla.Some thing")
                        LazyVGrid(columns: gridItemLayout, content: {
                            ForEach(0 ... 9999, id: \.self) { _ in
                                ArtistListCell()
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
            initialState: ArtistsFeature.State(),
            reducer: {
                ArtistsFeature()
            }
        )
    )
}
