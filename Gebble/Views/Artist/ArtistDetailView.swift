//
//  ArtistDetailView.swift
//  Gebble
//
//  Created by DjangoLin on 2023/11/7.
//

import ComposableArchitecture
import ScalingHeaderScrollView
import SwiftUI
import YouTubePlayerKit

struct ArtistsDetailFeature: Reducer {
    @Dependency(\.artistsClient) var artistsClient
    @Dependency(\.mainQueue) private var mainQueue

    enum Tab: Int {
        case about, journey, e1t1, video

        var title: String {
            switch self {
            case .about:
                return "About"
            case .journey:
                return "Journey"
            case .e1t1:
                return "E1T1"
            case .video:
                return "Video"
            }
        }
    }

    struct State: Equatable {
        var fetchArtist: String
        var currentTab: Tab = .about
        var tabs: [Tab] = [.about, .video, .journey, .e1t1]
        var portfolios: ArtistPortfolios?
        var bios: ArtistBio?
    }

    enum SwipeDirection {
        case left, right
    }

    enum Action: Equatable {
        case closeButtonClick
        case swipe(SwipeDirection)
        case onTabClick(Tab)
        case loadPortfolios
        case loadBios
        case portfoliosResponse(TaskResult<ArtistPortfolios>)
        case biosResponse(TaskResult<ArtistBio>)
    }

    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case let .swipe(direction):
            guard let index = state.tabs.firstIndex(of: state.currentTab) else {
                return .none
            }
            var targetIndex: Int = index
            switch direction {
            case .left:
                targetIndex = min(state.tabs.count - 1, index + 1)
            case .right:
                targetIndex = max(0, index - 1)
            }
            state.currentTab = state.tabs[targetIndex]
            return .none
        case let .onTabClick(tab):
            state.currentTab = tab
            return .none
        case .loadPortfolios:
            return .run { [artistName = state.fetchArtist] send in
                let portfoliosResponse = await TaskResult {
                    try await artistsClient.fetchArtistsPortfolios("\(artistName)")
                }
                await send(.portfoliosResponse(portfoliosResponse))
            }
        case .loadBios:
            return .run { [artistName = state.fetchArtist] send in
                let bioResponse = await TaskResult {
                    try await artistsClient.fetchArtistsBio("\(artistName)")
                }
                await send(.biosResponse(bioResponse))
            }
        case let .portfoliosResponse(.success(response)):
            state.portfolios = response
            return .none
        case let .biosResponse(.success(response)):
            state.bios = response
            return .none
        case .portfoliosResponse(.failure(_)), .biosResponse(.failure(_)):
            return .none
        case .closeButtonClick:
            return .none
        }
    }
}

struct ArtistDetailView: View {
    let store: StoreOf<ArtistsDetailFeature>

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

                ScalingHeaderScrollView {
                    header.placeholder(isLoading)
                } content: {
                    contentView.placeholder(isLoading) {
                        Text.textPlaceholder()
                    }
                }
                .height(min: minHeight, max: maxHeight)
                .collapseProgress($progress)
                .allowsHeaderCollapse()
                .ignoresSafeArea()

                navgationBar

                topButtons
            }
            .onAppear {
                Task {
                    isLoading = true
                    defer { isLoading = false }
                    await viewStore.send(.loadBios).finish()
                    await viewStore.send(.loadPortfolios).finish()
                }
            }
        }
    }

    private var header: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            ZStack {
                
                GebbleImage(url: viewStore.state.portfolios?.cover)
                    .aspectRatio(contentMode: .fill)
                    .clipped()
                    .cornerRadius(20)
                    .frame(minHeight: maxHeight)

               

                LinearGradient(colors: [.clear, .clear, .black.opacity(0.7)], startPoint: .top, endPoint: .bottom)

                VStack(alignment: .leading, spacing: 1) {
                    Spacer()
                    Text("Artist")
                        .font(.callout)
                        .foregroundColor(.base)
                    HStack {
                        Text("\(viewStore.state.portfolios?.artistName ?? "")")
                            .font(.title.bold())
                            .foregroundColor(.base)
                    }
                    tabs(id: "Large")
                }
                .padding(.bottom, 20)
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .opacity(1 - progress)
        }
    }

    private var topButtons: some View {
        WithViewStore(self.store, observe: \.bios) { viewStore in

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
        WithViewStore(self.store, observe: \.bios) { viewStore in

            VStack(spacing: 0) {
                HStack {
                    Text("\(viewStore.state?.username ?? "")")
                        .frame(height: 40)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .background(Color.base)

                tabs(id: "small")
                    .background(Color.base)

                Spacer()
            }
            .opacity(max(0, min(1, (progress - 0.75) * 4.0)))
        }
    }

    @ViewBuilder
    func tabs(id: String) -> some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 25) {
                        ForEach(viewStore.state.tabs, id: \.self) { tab in
                            VStack(spacing: 12) {
                                Text(tab.title)
                                    .fontWeight(.semibold)
                                    .foregroundColor(tab == viewStore.state.currentTab ? .brown : .gray)

                                ZStack {
                                    if viewStore.state.currentTab == tab {
                                        Capsule()
                                            .fill(.brown)
                                            .matchedGeometryEffect(id: "TAB\(id)", in: animation)
                                    } else {
                                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                                            .fill(.clear)
                                    }
                                }
                                .padding(.horizontal, 8)
                                .frame(height: 4)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                viewStore.send(.onTabClick(tab), animation: .easeInOut)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .frame(height: 47.0)
                }
            }
        }
    }

    private var contentView: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in

            VStack {
                HStack {
                    VStack {
                        switch viewStore.state.currentTab {
                        case .about:
                            about
                        case .journey:
                            jouney
                        case .e1t1:
                            e1t1
                        case .video:
                            video
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(24)
                }
                .frame(minHeight: UIScreen.main.bounds.height - maxHeight)
            }
            .background(Color.base)
            .mask(Rectangle().cornerRadius(12, corners: [.topLeft, .topRight])).offset(y: -10)
            .zIndex(progress == 1 ? 0 : 2).frame(width: UIScreen.main.bounds.width)
            .gesture(DragGesture(minimumDistance: 20, coordinateSpace: .global)
                .onEnded { value in
                    guard abs(value.velocity.width) > 500 else { return }
                    let horizontalAmount = value.translation.width
                    let verticalAmount = value.translation.height
                    if abs(horizontalAmount) > abs(verticalAmount) {
                        if horizontalAmount < 0 {
                            viewStore.send(.swipe(.left), animation: .easeInOut)
                        } else {
                            viewStore.send(.swipe(.right), animation: .easeInOut)
                        }
                    }
                })
        }
    }

    private var video: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack(alignment: .center, spacing: 20) {
                if let vidArr = viewStore.bios?.videos, vidArr.count > 0 {
                    ForEach(vidArr, id: \.id) { vid in
                        youtubeBuilder(url: vid.url)
                    }
                } else {
                    VStack {
                        HStack {
                            Image(systemName: "figure.yoga")
                            Text("Stay tune! This artist not upload any video yet")
                        }
                    }
                    .foregroundStyle(.gray)
                }
            }
        }
    }

    @Environment(\.openURL) var openURL

    private var about: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in

            VStack(alignment: .leading, spacing: 20) {
                if let contacts = viewStore.bios?.contacts, contacts.count > 0 {
                    HStack {
                        ForEach(contacts, id: \.id) { contact in
                            if let url = URL(string: contact.url!), UIApplication.shared.canOpenURL(url) {
                                Image("\(contact.type.imageName)")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .onTapGesture {
                                        openURL(url)
                                    }
                            }
                        }
                    }
                }

                if let crew = viewStore.bios?.crew, !crew.isEmpty {
                    Text("\(crew)").font(.title2)
                }

                if let quote = viewStore.bios?.quote,
                   let user = viewStore.state.portfolios?.artistName
                {
                    Divider()
                    HStack {
                        Text("\"\(quote)\" - \(user)").fontWeight(.thin).font(.callout.bold().italic())
                        if let coutry = viewStore.portfolios?.country {
                            let flag = convertStringToFlag(coutry)
                            Text("\(flag)")
                        }
                    }
                }

                if let intro = viewStore.portfolios?.introduction {
                    Divider()
                    Text("\(intro)").font(.body)
                }

                Spacer()
            }
        }
    }

    @ViewBuilder
    func youtubeBuilder(url: String) -> some View {
        YouTubePlayerView(
            .init(stringLiteral: "\(url)")
        ) {
            state in
            switch state {
            case .idle:
                ProgressView()
            case .ready:
                EmptyView()
            case .error:
                Text(verbatim: "YouTube player couldn't be loaded")
            }
        }
        .background(Color.gray.opacity(0.3))
        .frame(minHeight: 240)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var jouney: some View {
        WithViewStore(self.store, observe: { $0 }) { _ in
            VStack {
                HStack {
                    Image(systemName: "lock.fill")
                    Text("Access is not allowed.")
                }
                Text("To view their journey, you need to give a shoutout or get one and wait for approval.")
            }
            .foregroundStyle(.gray)
        }
    }

    private var e1t1: some View {
        WithViewStore(self.store, observe: { $0 }) { _ in
            VStack {
                HStack {
                    Image(systemName: "lock.fill")
                    Text("Access is not allowed.")
                }
                Text("To view their each 1 teach 1, you need to give a shoutout or get one and wait for approval.")
            }
            .foregroundStyle(.gray)
        }
    }
}

#Preview {
    ArtistDetailView(
        store: .init(initialState: ArtistsDetailFeature.State(fetchArtist: "yiyasha"),
                     reducer: {
                         ArtistsDetailFeature()
                     })
    )
}
