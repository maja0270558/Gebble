//
//  WorkshopDetailView.swift
//  Gebble
//
//  Created by DjangoLin on 2023/11/20.
//

import ComposableArchitecture
import Kingfisher
import ScalingHeaderScrollView
import SwiftUI
import YouTubePlayerKit
import Nuke
import NukeUI

struct WorkshopDetailFeature: Reducer {
    @Dependency(\.workshopClient) var workshopClient
    @Dependency(\.mainQueue) private var mainQueue

    struct State: Equatable {
        var fetchWorkshopId: String
        var detail: WorkshopDetail?
    }

    enum Action: Equatable {
        case closeButtonClick
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

        case .closeButtonClick:
            return .none
        }
    }
}

struct WorkshopDetailView: View {
    let store: StoreOf<WorkshopDetailFeature>

    private let minHeight = 150.0
    private let maxHeight = UIScreen.main.bounds.height / 2

    @State var progress: CGFloat = 0
    @State var isLoading = false

    @Namespace var animation
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            ZStack {
                Color.base.ignoresSafeArea()

                ScrollView {
                    VStack {
                        
                        AsyncImage(url: URL(string: "\(viewStore.state.detail?.poster ?? "")"  ), content: { image in
                                   image.cornerRadius(20, corners: .allCorners)

                               }, placeholder: {
                                   ProgressView()
                               })
                        .scaledToFill()
                        .cornerRadius(20, corners: .allCorners)
                        
                        LazyImage(url: URL(string: "\(viewStore.state.detail?.poster ?? "")"  )) {
                            state in
                            if let image = state.image {
                                image.resizable()
                                    .scaledToFill()
                                    .cornerRadius(500, corners: .allCorners)
                            }
                        }
                       
                        KFImage(URL(string: "\(viewStore.state.detail?.poster ?? "")"))
                          .resizable()
                          .scaledToFill()
                          .cornerRadius(20, corners: .allCorners)
                          
                     

                        Text("Title")
                            .font(.callout)
                        HStack {
                            Text("\(viewStore.state.detail?.title ?? "")")
                                .font(.title.bold())
                        }

                        Text("Date")
                            .font(.callout)

                        HStack {
                            Text("\(viewStore.state.detail?.startDate ?? "")")
                                .font(.title.bold())
                        }

                        Text("content")
                            .font(.callout)

                        HStack {
                            Text("\(viewStore.state.detail?.content ?? "")")
                                .font(.title.bold())
                        }

                        Spacer()
                    }
                }
                .padding(.horizontal, 20)
            }
            .onAppear {
                Task {
                    isLoading = true
                    defer { isLoading = false }
                    await viewStore.send(.load).finish()
                }
            }
        }
    }

    private var header: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            ZStack {
                KFImage(URL(string: viewStore.state.detail?.poster ?? ""))
                    .placeholder {
                        Image(systemName: "person")
                            .resizable()
                            .redacted(reason: .placeholder)
                    }
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipped()
                    .cornerRadius(20)
                    .frame(minHeight: maxHeight)
            }
            .opacity(1 - progress)
        }
    }

    private var topButtons: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in

            VStack {
                HStack {
                    Button("", action: { viewStore.send(.closeButtonClick) })
                        .buttonStyle(CircleButtonStyle(imageName: "arrow.backward"))
                        .padding(.leading, 17)
                    Spacer()
                    Button("", action: { print("Info") })
                        .buttonStyle(CircleButtonStyle(imageName: "ellipsis"))
                        .padding(.trailing, 17)
                }

                Spacer()
            }
        }
    }

    private var navgationBar: some View {
        WithViewStore(self.store, observe: \.detail) { viewStore in

            VStack(spacing: 0) {
                HStack {
                    Text("\(viewStore.state?.name1 ?? "")")
                        .frame(height: 40)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .background(Color.base)

                Spacer()
            }
            .opacity(max(0, min(1, (progress - 0.75) * 4.0)))
        }
    }
//
//
//    private var video: some View {
//        WithViewStore(self.store, observe: { $0 }) { viewStore in
//            VStack(alignment: .center, spacing: 20) {
//                if let vidArr = viewStore.bios?.videos, vidArr.count > 0 {
//                    ForEach(vidArr, id: \.id) { vid in
//                        youtubeBuilder(url: vid.url)
//                    }
//                } else {
//                    VStack {
//                        HStack {
//                            Image(systemName: "figure.yoga")
//                            Text("Stay tune! This artist not upload any video yet")
//                        }
//                    }
//                    .foregroundStyle(.gray)
//                }
//            }
//        }
//    }
//
//    @Environment(\.openURL) var openURL
//
//    private var about: some View {
//        WithViewStore(self.store, observe: { $0 }) { viewStore in
//
//            VStack(alignment: .leading, spacing: 20) {
//                if let contacts = viewStore.bios?.contacts, contacts.count > 0 {
//                    HStack {
//                        ForEach(contacts, id: \.id) { contact in
//                            if let url = URL(string: contact.url!), UIApplication.shared.canOpenURL(url) {
//                                Image("\(contact.type.imageName)")
//                                    .resizable()
//                                    .frame(width: 40, height: 40)
//                                    .onTapGesture {
//                                        openURL(url)
//                                    }
//                            }
//                        }
//                    }
//                }
//
//                if let crew = viewStore.bios?.crew, !crew.isEmpty {
//                    Text("\(crew)").font(.title2)
//                }
//
//                if let quote = viewStore.bios?.quote,
//                   let user = viewStore.state.portfolios?.artistName
//                {
//                    Divider()
//                    HStack {
//                        Text("\"\(quote)\" - \(user)").fontWeight(.thin).font(.callout.bold().italic())
//                        if let coutry = viewStore.portfolios?.country {
//                            let flag = convertStringToFlag(coutry)
//                            Text("\(flag)")
//                        }
//                    }
//                }
//
//                if let intro = viewStore.portfolios?.introduction {
//                    Divider()
//                    Text("\(intro)").font(.body)
//                }
//
//                Spacer()
//            }
//        }
//    }
//
//    @ViewBuilder
//    func youtubeBuilder(url: String) -> some View {
//        YouTubePlayerView(
//            .init(stringLiteral: "\(url)")
//        ) {
//            state in
//            switch state {
//            case .idle:
//                ProgressView()
//            case .ready:
//                EmptyView()
//            case .error:
//                Text(verbatim: "YouTube player couldn't be loaded")
//            }
//        }
//        .background(Color.gray.opacity(0.3))
//        .frame(minHeight: 240)
//        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
//    }
//
//    private var jouney: some View {
//        WithViewStore(self.store, observe: { $0 }) { _ in
//            VStack {
//                HStack {
//                    Image(systemName: "lock.fill")
//                    Text("Access is not allowed.")
//                }
//                Text("To view their journey, you need to give a shoutout or get one and wait for approval.")
//            }
//            .foregroundStyle(.gray)
//        }
//    }
//
//    private var e1t1: some View {
//        WithViewStore(self.store, observe: { $0 }) { _ in
//            VStack {
//                HStack {
//                    Image(systemName: "lock.fill")
//                    Text("Access is not allowed.")
//                }
//                Text("To view their each 1 teach 1, you need to give a shoutout or get one and wait for approval.")
//            }
//            .foregroundStyle(.gray)
//        }
//    }
}

#Preview {
    WorkshopDetailView(
        store: .init(initialState: WorkshopDetailFeature.State(fetchWorkshopId: "5b65ff41-c880-497f-a9a5-5e4f9b0b48ff"),
                     reducer: {
                         WorkshopDetailFeature()
                     })
    )
}

#Preview("2") {
    WorkshopDetailView(
        store: .init(initialState: WorkshopDetailFeature.State(fetchWorkshopId: "f8b11400-d4c7-4411-baaf-8f73de98e798"),
                     reducer: {
                         WorkshopDetailFeature()
                     })
    )
}

#Preview("3") {
    WorkshopDetailView(
        store: .init(initialState: WorkshopDetailFeature.State(fetchWorkshopId: "f455db5f-972b-40cd-867b-de8be31a25a2"),
                     reducer: {
                         WorkshopDetailFeature()
                     })
    )
}
