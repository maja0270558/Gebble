//
//  ContentView.swift
//  Gebble
//
//  Created by DjangoLin on 2023/10/23.
//

import Combine
import Popovers
import SwiftUI
import PagerTabStripView

struct ContentView: View {
    init() {}

    @State var present = false
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
                .onTapGesture {}
            Text("Hello, world!")

            Button("Present popover!") {
                present = true
            }
            .popover(present: $present) { /// here!
                Text("Hi, I'm a popover.")
                    .padding()
                    .foregroundColor(.white)
                    .background(.blue)
                    .cornerRadius(16)
            }
        }
        .padding()
    }
}

#Preview {
    TestProfileView()
}
  
struct TestProfileView: View {
    let headerHeight: CGFloat = 300
    let tabBarHeight: CGFloat = 50

    static let tab1Height: CGFloat = 100
    static let tab2Height: CGFloat = 800

    @State var tabIndex = 0
    @GestureState var dragOffset = CGSize.zero

    var body: some View {

        // The GeometryReader must contain the ScrollReader, not
        // the other way around, otherwise scrolling doesn't work
        GeometryReader { geometryProxy in
            ScrollViewReader { scrollViewProxy in
                ScrollView {
                    VStack(spacing: 0) {
                        header.id(0)
                        bottom(viewWidth: geometryProxy.size.width)
                    }
                }
                // Scroll back to the header when the tab changes
                .onChange(of: tabIndex) { newValue in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        scrollViewProxy.scrollTo(0)
                    }
                }
            }
        }
    }

    private var header: some View {
        Text("Header")
            .frame(maxWidth: .infinity)
            .frame(height: headerHeight)
            .background(Color.green)
    }

    private func bottom(viewWidth: CGFloat) -> some View {
        LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {
            Section {
                pager(viewWidth: viewWidth)
            } header: {
                tabBar(viewWidth: viewWidth)
            }
        }
    }

    private func tabBar(viewWidth: CGFloat) -> some View {
        HStack(spacing: 0) {
            tab(title: "Tab 1", at: 0, viewWidth: viewWidth)
            tab(title: "Tab 2", at: 1, viewWidth: viewWidth)
        }
        .frame(maxWidth: .infinity)
        .frame(height: tabBarHeight)
        .background(Color.gray)
    }

    private func tab(title: String, at index: Int, viewWidth: CGFloat) -> some View {
        Button {
            withAnimation {
                tabIndex = index
            }
        } label: {
            Text(title)
                .foregroundColor(.black)
                .frame(width: viewWidth / 2)
        }
    }

    func selectByDrag(viewWidth: CGFloat) -> some Gesture {
        DragGesture()
            .updating($dragOffset) { value, state, transaction in
                let translation = value.translation

                // Only interested in horizontal drag
                if abs(translation.width) > abs(translation.height) {
                    state = translation
                }
            }
            .onEnded { value in
                let translation = value.translation

                // Switch view if the translation is more than a
                // threshold (half the view width)
                if abs(translation.width) > abs(translation.height) &&
                    abs(translation.width) > viewWidth / 2 {
                    tabIndex = translation.width > 0 ? 0 : 1
                }
            }
    }

    private func pager(viewWidth: CGFloat) -> some View {
        
     
        HStack(alignment: .top, spacing: 0) {
            
            PagerTabStripView {
                HStack {
                    Spacer()
                    Text("Content 1")
                        .background(Color.yellow)
                        .frame(width: viewWidth, height: Self.tab1Height)
                        .pagerTabItem(tag: 1) {
                            Text("1")
                        }

                }
              
                Text("Content 2")
                    .background(Color.orange)
                    .frame(width: viewWidth, height: Self.tab2Height)
                    .pagerTabItem(tag: 2) {
                        Text("2")
                    }

            }
            .frame(width: viewWidth, height: Self.tab2Height)

            Text("Content 1")
                .frame(width: viewWidth, height: Self.tab1Height)
                .background(Color.yellow)
            Text("Content 2")
                .frame(width: viewWidth, height: Self.tab2Height)
                .background(Color.orange)
        }
        .fixedSize()
        .offset(x: (CGFloat(-tabIndex) * viewWidth) + dragOffset.width)
        .animation(.easeInOut, value: tabIndex)
        .animation(.easeInOut, value: dragOffset)
        .gesture(selectByDrag(viewWidth: viewWidth))
    }
}
