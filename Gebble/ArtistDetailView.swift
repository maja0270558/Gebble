//
//  ArtistDetailView.swift
//  Gebble
//
//  Created by DjangoLin on 2023/11/7.
//

import ComposableArchitecture
import ScalingHeaderScrollView
import SwiftUI

struct ArtistsDetailFeature: Reducer {
    enum Tab: Int {
        case about, journey, e1t1

        var title: String {
            switch self {
            case .about:
                return "About"
            case .journey:
                return "Journey"
            case .e1t1:
                return "E1T1"
            }
        }
    }

    @Dependency(\.artistsClient) var artistsClient
    @Dependency(\.mainQueue) private var mainQueue

    struct State: Equatable {
        var currentTab: Tab
        var tabs: [Tab] = [.about, .journey, .e1t1]
    }

    enum SwipeDirection {
        case left, right
    }

    enum Action: Equatable {
        case swipe(SwipeDirection)
        case onTabClick(Tab)
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
        }
    }
}

struct ArtistDetailView: View {
    let store: StoreOf<ArtistsDetailFeature>

    // 2 api get bio, profolio
    private let minHeight = 150.0
    private let maxHeight = UIScreen.main.bounds.height / 2
    @State var progress: CGFloat = 0

    @Namespace var animation
    @Environment(\.dismiss) var dismiss

    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            ZStack {
                Color.base.ignoresSafeArea()

                ScalingHeaderScrollView {
                    header
                } content: {
                    contentView
                }
                .height(min: minHeight, max: maxHeight)
                .collapseProgress($progress)
                .allowsHeaderCollapse()
                .ignoresSafeArea()

                navgationBar
                
                topButtons
            }
        }
    }

    private var header: some View {
        ZStack {
            Image("out")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .clipped()
                .cornerRadius(20)
                .frame(minHeight: maxHeight)

            LinearGradient(colors: [.clear, .clear, .black.opacity(0.7)], startPoint: .top, endPoint: .bottom)

            VStack(alignment: .leading, spacing: 1) {
                Spacer()
                Text("ARTIST")
                    .font(.callout)
                    .foregroundColor(.base)
                HStack {
                    Text("Hiking holic")
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

    private var topButtons: some View {
        VStack {
            HStack {
                Button("", action: {})
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

    private var navgationBar: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Hiking holic")
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
                        //                    if currentType == 0 {
                        //                        description
                        //                    } else if currentType == 1 {
                        //                        userName
                        //                    } else {
                        //                        address
                        //                    }
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

}

#Preview {
    ArtistDetailView(
        store: .init(initialState: .init(currentTab: .about),
                     reducer: {
                         ArtistsDetailFeature()
                     })
    )
}
