//
//  WorkshopView.swift
//  Gebble
//
//  Created by DjangoLin on 2023/11/11.
//

import ComposableArchitecture
import SwiftUI

struct WorkshopFeature: Reducer {
    struct WorkshopRequestParameter: Equatable {
        var name: String
        var filter: WorkshopFilterValue
    }

    typealias WorkshopsResult = CollectionLoadingState<[WorkshopList.WorkshopListItem]>
    @Dependency(\.workshopClient) var workshopClient
    @Dependency(\.collectionStateStreamMaker) var dataAsyncStream
    @Dependency(\.mainQueue) private var mainQueue
    private enum CancelID { case workshopRequest }
    internal enum WorkshopListResultType { case all, search }

    struct State: Equatable {
        @PresentationState var filter: WorkshopFilterFeature.State?
        var search: GebbleSearchBarFeature.State = .init(queryString: "",
                                                         isFocused: false)
        var currentFilter: WorkshopFilterValue = WorkshopFilter.initFilter
        var currentCollectionState: WorkshopsResult = .unload
        var lastSearchValue: Action = .initLoad
    }

    enum Action: Equatable {
        case filter(PresentationAction<WorkshopFilterFeature.Action>)
        case search(GebbleSearchBarFeature.Action)
        case load(name: String, filter: WorkshopFilterValue)
        case initLoad
        case listResponse(WorkshopsResult)
        case refresh
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.search, action: /Action.search) {
            GebbleSearchBarFeature()
        }

        Reduce { state, action in
            switch action {
            case .refresh:
                state.lastSearchValue = .refresh
                return .send(.load(name: state.search.queryString, filter: state.currentFilter))
            case .initLoad:
                return .send(.load(name: "", filter: WorkshopFilter.initFilter))
            case let .load(name, filter):
                guard state.lastSearchValue != .load(name: name, filter: filter) else {
                    return .none
                }
                state.lastSearchValue = .load(name: name, filter: filter)
                return .run { send in
                    // load all
                    var stream: AsyncStream<CollectionLoadingState<[WorkshopList.WorkshopListItem]>>

                    stream = await dataAsyncStream.maker.asyncStreamState(placeholder: WorkshopList.WorkshopListItem.placeholder) {
                        if filter == WorkshopFilter.initFilter, name.isEmpty {
                            let list = try await workshopClient.fetchAllWorkshopList()
                            return list.results
                        } else {
                            let list = try await workshopClient.searchWorkshops(name, filter)
                            return list
                        }
                    }

                    await foreachStream(stream: stream) { state in
                        await send(.listResponse(state))
                    }
                }
                .cancellable(id: CancelID.workshopRequest, cancelInFlight: true)
            case let .listResponse(response):
                state.currentCollectionState = response
                return .none
            case let .search(action):
                return searchReducer(into: &state, action: action)
            case let .filter(action):
                return filterReducer(into: &state, action: action)
            }
        }
        .ifLet(\.$filter, action: /Action.filter) {
            WorkshopFilterFeature()
        }
    }

    private func searchReducer(into state: inout State, action: GebbleSearchBarFeature.Action) -> Effect<Action> {
        switch action {
        // Search API current don't accept mutiple query
        case .delegate(.onFilterClick):
            state.filter = .init(filter: state.currentFilter)
            return .none
        case .delegate(.onCleanQueryClick):
            state.search.queryString = ""
            state.search.isFocused = false
            return .send(.load(name: state.search.queryString, filter: state.currentFilter))

        case let .delegate(.onQueryChange(query)):
            state.search.queryString = query
            return .send(.load(name: state.search.queryString, filter: state.currentFilter))
        default:
            return .none
        }
    }

    private func filterReducer(into state: inout State, action: PresentationAction<WorkshopFilterFeature.Action>) -> Effect<Action> {
        switch action {
        case .dismiss:
            return .none
        case let .presented(.delegate(delegate)):
            switch delegate {
            case .onApplyClick:
                state.currentFilter = state.filter!.filter
                state.filter = nil
                state.search.containFilterValue = state.currentFilter != WorkshopFilter.initFilter
            case .onResetClick:
                state.currentFilter = WorkshopFilter.initFilter
                state.filter = nil
                state.search.containFilterValue = false
            case .onCloseClick:
                state.filter = nil
                return .none
            case let .onCountryClick(country):
                state.filter?.filter.country = country
                return .none
            }
            return .send(.load(name: state.search.queryString, filter: state.currentFilter))
        default:
            return .none
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
                    .safeAreaInset(edge: .bottom, content: {
                        EmptyView()
                    })
                    .offset(y: 60)
                    .padding()
                    .navigationTitle("Workshop")
                    .toolbar(viewStore.search.isFocused ? .hidden : .automatic, for: .navigationBar)
                }
                .refreshable {
                    viewStore.send(.refresh)
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
            .sheet(store: self.store.scope(state: \.$filter,
                                           action: { .filter($0) }),
                   content: { store in
                       WorkshopFilter(store: store)
                   })
            .onViewDidLoad {
                viewStore.send(.initLoad)
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
