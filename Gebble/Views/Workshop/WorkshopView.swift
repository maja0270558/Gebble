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

        internal var result: [WorkshopListResultType: WorkshopsResult] = [
            .all: .unload,
            .search: .unload
        ]
    }

    enum Action: Equatable {
        case load
        case listResponse(WorkshopListResultType, WorkshopsResult)
        case search(String)
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .load:
                return .run { send in
                    let stream = await dataAsyncStream.maker.asyncStreamState(placeholder: WorkshopList.WorkshopListItem.placeholder) {
                        let list = try await workshopClient.fetchAllWorkshopList()
                        return list.results
                    }

                    await foreachStream(stream: stream) { state in
                        print(state)
                        await send(.listResponse(.all, state))
                    }
                }
                .debounce(id: CancelID.workshopRequest, for: 0.5, scheduler: mainQueue)
                .cancellable(id: CancelID.workshopRequest)
            case let .listResponse(type, response):
                state.result[type] = response
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
            NavigationBaseView(makeContent: {
                ScrollView {
                    VStack(alignment: .leading) {
                       

                        Text("Explore workshop")
                            .font(.headline)
                        Text("Some thing  blablabla.Some thing  blablabla.Some thing  blablabla.Some thing")

                        CollectionLoadingView(loadingState: viewStore.state.currentCollectionState) { items in

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

                        } empty: {
                            Text("empty")
                        } error: { _ in
                            Text("error")
                        }
                    }
                    .padding()
                    .navigationTitle("Workshop")
                }
                .refreshable {
//                    viewStore.send(.refresh)
                }

            })
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
