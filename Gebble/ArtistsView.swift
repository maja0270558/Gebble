//
//  ArtistsView.swift
//  Gebble
//
//  Created by DjangoLin on 2023/10/24.
//

import ActivityIndicatorView
import ComposableArchitecture
import Kingfisher
import Shimmer
import SwiftUI
import SwiftUIPullToRefresh

struct ArtistsFeature: Reducer {
    @Dependency(\.artistsClient) var artistsClient
    @Dependency(\.collectionStateStreamMaker) var collectionStateMaker
    @Dependency(\.mainQueue) private var mainQueue

    private enum CancelID { case artistsRequest, searchRequest }

    typealias ArtistsResult = CollectionLoadingState<[ArtistList.ArtistListItem]>
    internal enum ArtistListResultType { case all, search }

    struct State: Equatable {
        var currentCollectionState: ArtistsResult = .unload
        var searchQuery: String = ""

        internal var result: [ArtistListResultType: ArtistsResult] = [
            .all: .unload,
            .search: .unload
        ]
    }

    enum Action: Equatable {
        case artistCellTap(ArtistList.ArtistListItem)
        case loadArtists
        case refresh
        case searchArtists(String)
        case artistListResponse(ArtistListResultType, ArtistsResult)
    }
    
    func forWaitAndFire<T>(stream: AsyncStream<T>,_ fire: (T) async -> Void) async {
        for await state in stream {
            await fire(state)
        }
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
                if let stateOfAll = state.result[.all], stateOfAll != .unload {
                    return .send(.artistListResponse(.all, stateOfAll))
                }
                return .send(.loadArtists)
            }
    
            return .run { [query = state.searchQuery] send in
                let stream = await collectionStateMaker.maker.asyncStreamState(placeholder: ArtistList.ArtistListItem.placeholder) {
                    let list = try await artistsClient.searchArtists(query)
                    return list
                }
                
                await forWaitAndFire(stream: stream) { state in
                    await send(.artistListResponse(.search, state))
                }
                

            }
            .debounce(id: CancelID.searchRequest, for: 0.5, scheduler: mainQueue)
            .cancellable(id: CancelID.searchRequest, cancelInFlight: true)

        case .loadArtists:
            Task.cancel(id: CancelID.artistsRequest)
            
            return .run { send in
                let stream = await collectionStateMaker.maker.asyncStreamState(placeholder: ArtistList.ArtistListItem.placeholder) {
                    let list = try await artistsClient.fetchArtistList()
                    return list.results
                }
                
                await forWaitAndFire(stream: stream) { state in
                    await send(.artistListResponse(.all, state))
                }

            }
            .debounce(id: CancelID.artistsRequest, for: 0.5, scheduler: mainQueue)
            .cancellable(id: CancelID.artistsRequest)

        case let .artistListResponse(type, response):
            state.result[type] = response
            state.currentCollectionState = response
            return .none
        }
    }
}

struct ArtistListCell: View {
    var artist: ArtistList.ArtistListItem
    let animation: Namespace.ID
    var imageURL: URL? {
        return artist.thumb.isEmpty ? nil : URL(string: "\(artist.thumb)")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            KFImage(imageURL)
                .placeholder {
                    Image(systemName: "person")
                        .resizable()
                        .redacted(reason: .placeholder)
                }
                .resizable()
                .aspectRatio(1, contentMode: .fill)
                .matchedGeometryEffect(id: "\(artist.artistName)", in: animation)
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
            .padding(4)
            .frame(height: 20)
        }
        .background(Color.base)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.gray, lineWidth: 0.2).unredacted()
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
    @State var show: Bool = false
    @State var currFullId = ""

    @Namespace var animation

    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in

            ZStack {
                if show {
                    ScrollView(showsIndicators: false) {
                        ZStack(alignment: .bottom) {
                            // MARK: - Header

                            VStack(spacing: 0) {
                                Image("Gebbles6")
                                    .resizable()
                                    .matchedGeometryEffect(id: "\(currFullId)", in: animation, anchor: .top)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 240)
                                    .padding(.vertical, 2*24)
                                Spacer()
                                    .frame(height: UIScreen.main.bounds.height - 92 + 2*24)
                            }
                            .frame(width: UIScreen.main.bounds.width)
                            .onTapGesture { _ in
                                withAnimation(.linear) {
                                    show.toggle()
                                }
                            }
                        }
                    }

                } else {
                    // OGView
                    NavigationStack {
                        ZStack {
                            // Full detail
                            Color.base.ignoresSafeArea(.all)

                            ScrollView {
                                VStack(alignment: .leading) {
                                    Divider()

                                    Text("Explore artist")
                                        .font(.headline)
                                    Text("Some thing  blablabla.Some thing  blablabla.Some thing  blablabla.Some thing")

                                    CollectionLoadingView(loadingState: viewStore.state.currentCollectionState) { items in

                                        LazyVGrid(columns: gridItemLayout) {
                                            ForEach(items, id: \.artistName) { artist in
                                                ArtistListCell(artist: artist, animation: animation)
                                                    .onTapGesture { _ in
                                                        currFullId = "\(artist.artistName)"

                                                        withAnimation(.linear) {
                                                            show.toggle()
                                                        }
                                                    }
                                            }
                                        }

                                    } empty: {
                                        Text("empty")
                                    } error: { _ in
                                        Text("error")
                                    }
                                }
                                .padding()
                                .navigationTitle("Artists")
                            }
                            .refreshable {
                                viewStore.send(.refresh)
                            }
                        }

                    }.onAppear {
                        let appearance = UINavigationBarAppearance()
                        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
                        appearance.backgroundColor = UIColor(Color.base.opacity(0.2))
                        UINavigationBar.appearance().scrollEdgeAppearance = appearance
                        // Inline appearance (standard height appearance)
                        UINavigationBar.appearance().standardAppearance = appearance
                        // Large Title appearance
                        UINavigationBar.appearance().scrollEdgeAppearance = appearance
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
                }
            }
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
