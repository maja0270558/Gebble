//
//  WorkshopView.swift
//  Gebble
//
//  Created by DjangoLin on 2023/11/11.
//

import ComposableArchitecture
import SwiftUI

struct WorkshopFeature: Reducer {
    typealias WorkshopsResult = CollectionLoadingState<[WorkshopList.WorkshopListItem]>
    @Dependency(\.workshopClient) var workshopClient
    @Dependency(\.collectionStateStreamMaker) var dataAsyncStream
    @Dependency(\.mainQueue) private var mainQueue
    private enum CancelID { case workshopRequest, searchRequest }
    internal enum WorkshopListResultType { case all, search }

    struct State: Equatable {
        var currentCollectionState: WorkshopsResult = .unload
        var searchQuery: String = ""
        var search: GebbleSearchBarFeature.State = .init(queryString: "", isFocused: false)
    }

    enum Action: Equatable {
        case search(GebbleSearchBarFeature.Action)
        case load
        case listResponse(WorkshopsResult)
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.search, action: /Action.search) {
            GebbleSearchBarFeature()
        }
        Reduce { state, action in
            switch action {
            case .load:
                return .run { send in
                    let stream = await dataAsyncStream.maker.asyncStreamState(placeholder: WorkshopList.WorkshopListItem.placeholder) {
                        let list = try await workshopClient.fetchAllWorkshopList()
                        return list.results
                    }

                    await foreachStream(stream: stream) { state in
                        await send(.listResponse(state))
                    }
                }
                .debounce(id: CancelID.workshopRequest, for: 0.5, scheduler: mainQueue)
                .cancellable(id: CancelID.workshopRequest)
            case let .listResponse(response):
                state.currentCollectionState = response
                return .none
            case .search:
                return .none
            }
        }
    }
}

struct WorkshopView: View {
    let store: StoreOf<WorkshopFeature>
    var gridItemLayout = [GridItem(.flexible(), spacing: 4),
                          GridItem(.flexible(), spacing: 0)]

    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationBaseView {
                ScrollView {
                    VStack(alignment: .leading) {
                       

                        CollectionLoadingView(loadingState: viewStore.state.currentCollectionState) { items in
                            VStack {
                                Text("Explore workshop")
                                    .font(.headline)
                                Text("Unveiling Creativity: Journeying Through Engaging Workshops")
                                
                                LazyVGrid(columns: gridItemLayout, spacing: 4) {
                                    ForEach(items, id: \.id) { workshop in
                                        GebbleImageCell(image: workshop.poster,
                                                        title: workshop.title,
                                                        flag: workshop.country)
                                            .onTapGesture {
    //                                            viewStore.send(.clickArtist(artist.username))
                                            }
                                    }
                                }
                            }
                        } empty: {
                            GebbleEmptyView(title: "So quient here....")
                        } error: { error in
                            GebbleErrorView(title: error.localizedDescription)
                        }
                    }
                    .offset(y: 60)
                    .padding()
                    .navigationTitle("Workshop")
                    .navigationBarHidden(viewStore.search.isFocused)
                }

                .refreshable {
//                    viewStore.send(.refresh)
                }
                .overlay(content: {
                    VStack {
                        GebbleSearchBar(store: self.store.scope(state: \.search,
                                                                action: { .search($0) }),
                                        prompt: "Search workshop",
                                        filter: true)
                        Spacer()
                    }
                    .padding()

                })
            }
            .onTapGesture {
                hideKeyboard()
            }
            .onViewDidLoad {
                viewStore.send(.load)
            }
        }
    }
}

#Preview {
    WorkshopView(store: Store(initialState: WorkshopFeature.State(),
                              reducer: {
                                  WorkshopFeature()
                              }))
}