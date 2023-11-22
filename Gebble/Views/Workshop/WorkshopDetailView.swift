//
//  WorkshopDetailView.swift
//  Gebble
//
//  Created by DjangoLin on 2023/11/20.
//

import ComposableArchitecture
import ScalingHeaderScrollView
import SwiftUI
import YouTubePlayerKit

struct WorkshopDetailFeature: Reducer {
    @Dependency(\.workshopClient) var workshopClient
    @Dependency(\.mainQueue) private var mainQueue
    @Dependency(\.sharedState) var shareStateClient
    struct State: Equatable {
        var fetchWorkshopId: String
        var detail: WorkshopDetail?
    }

    enum Action: Equatable {
        case attendWorkshoptaped
        case load
        case detailResponse(TaskResult<WorkshopDetail>)
    }

    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .load:
            return .run { [id = state.fetchWorkshopId] send in
                let portfoliosResponse = await TaskResult {
                    try await workshopClient.fetchArtistDetail(id)
                }
                await send(.detailResponse(portfoliosResponse))
            }

        case let .detailResponse(result):
            switch result {
            case let .success(response):
                state.detail = response
            default:
                return .none
            }
            return .none

        case .attendWorkshoptaped:
            shareStateClient.update(\.globalStore, action: .loginViewPresent(true))
            return .none
        }
    }
}

struct WorkshopDetailView: View {
    let store: StoreOf<WorkshopDetailFeature>
    @State var isLoading = false

    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            ZStack {
                Color.base.ignoresSafeArea()

                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0, pinnedViews: [.sectionHeaders]) {
                        topImage
                        sectionTitle
                        sectiionContent
                        Spacer()
                    }
                }
                .placeholder(isLoading)

                .safeAreaInset(edge: .bottom, content: {
                    bottomRegisterButton
                })
            }
            .navigationTitle("\(viewStore.detail?.name1 ?? "")")
            .onAppear {
                Task {
                    isLoading = true
                    defer { isLoading = false }
                    await viewStore.send(.load).finish()
                }
            }
        }
    }

    private var topImage: some View {
        WithViewStore(self.store, observe: \.detail) { viewStore in
            GebbleImage(url: viewStore.state?.poster)
                .scaledToFill()
                .background(.white)
                .cornerRadius(20, corners: [.bottomLeft, .bottomRight])
                .shadow(radius: 5)
        }
    }

    private var sectionTitle: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            
            Section {
                Group {
                    HStack {
                        Image(systemName: "person")
                        Text("\(viewStore.state.detail?.name1 ?? "")")
                    }

                    HStack {
                        HStack {
                            Image(systemName: "calendar")
                            Text("\(viewStore.state.detail?.startDate ?? "") \(viewStore.state.detail?.datetime ?? "")")
                        }
                        Spacer()
                        HStack {
                            Image(systemName: "mappin.and.ellipse")
                            Text("\(viewStore.state.detail?.country ?? "") \(viewStore.state.detail?.venue ?? "")")
                        }
                    }
                }
                .padding(.horizontal)
            } header: {
                HStack {
                    Text("\(viewStore.state.detail?.title ?? "")")
                        .font(.title.bold())
                    Spacer()
                }
                .padding()
                .background(Color.base)
            }

            
        }
    }

    private var sectiionContent: some View {
        WithViewStore(self.store, observe: \.detail) { viewStore in
            Section {
                HStack {
                    if let content = viewStore.state?.content {
                        if content.isEmpty {
                            VStack(alignment: .center) {
                                Text("Creator left a blank space behind 😇")
                                    .foregroundStyle(.gray)
                            }
                           
                        } else {
                            Text("\(content)")
                        }
                    }
                }.padding()
                    .placeholder(isLoading) {
                        Text.textPlaceholder()
                    }

            } header: {
                HStack {
                    Text("About the workshop")
                        .font(.title.bold())
                    Spacer()
                }
                .padding()
                .background(Color.base)
            }
        }
    }
    
    private var bottomRegisterButton:  some View {
        WithViewStore(self.store, observe: \.detail) { viewStore in
            Button(action: {
                viewStore.send(.attendWorkshoptaped)
            }, label: {
                Text("Register")
                    .bold()
                    .frame(height: 65)
                    .frame(maxWidth: .infinity)
                    .background(.brown)
                    .foregroundColor(.white)
                    .cornerRadius(12, corners: .allCorners)
                    .padding()
            })
        }

    }

}

#Preview {
    WorkshopDetailView(
        store: .init(initialState: WorkshopDetailFeature.State(fetchWorkshopId: "e18df064-bb6c-48b3-86b8-d91eb000b5eb"),
                     reducer: {
                         WorkshopDetailFeature()
                     })
    )
}
