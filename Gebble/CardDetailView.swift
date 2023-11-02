//
//  CardDetailView.swift
//  Gebble
//
//  Created by DjangoLin on 2023/11/2.
//

import SwiftUI
struct CloseButton: View {
    @Binding var isShowingDetail: Bool
    
    var body: some View {
        Image(systemName: "xmark")
            .font(.system(size: 16))
            .frame(width: 32, height: 32)
            .foregroundColor(.black)
            .background(.white)
            .clipShape(Circle())
            .onTapGesture {
                withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.85, blendDuration: 0.25)) {
                    isShowingDetail = false
                }
            }
    }
}


struct CardDetail: View {
    // MARK: - Properties
    @Binding var isShowingDetail: Bool
    @Binding var isAppeared: Bool
    let animation: Namespace.ID
    
    // MARK: - Private State
    @State private var animateText: Bool = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            ZStack(alignment: .bottom) {
                // MARK: - Header
                VStack(spacing: 0) {
                    Image("Gebbles6")
                        .resizable()
                        .matchedGeometryEffect(id: "image", in: animation, anchor: .top)
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 240)
                        .padding(.vertical, 2*24)
                    Spacer()
                        .frame(height: UIScreen.main.bounds.height - 92 + 2*24)
                }
                .frame(width: UIScreen.main.bounds.width)
                .background(
                    Color.black
                        .cornerRadius(0)
                        .matchedGeometryEffect(id: "background", in: animation)
                )
                // MARK: - Content
                VStack(alignment: .leading, spacing: 0) {
                    Text("Title")
                        .matchedGeometryEffect(id: "title", in: animation)
                        .padding(.bottom, 16)
                    HStack(spacing: 12) {
                        Text("subtitle")
                            .matchedGeometryEffect(id: "AnimationId.label1Id", in: animation)
                        Text("cat")
                            .matchedGeometryEffect(id: "AnimationId.label2Id", in: animation)
                    }
                    .padding(.bottom, 24)
                    Text("Content")
                        .opacity(animateText ? 1 : 0)
                }
                .padding(24)
                .background(
                    Color.white
//                        .cornerRadius(Dimens.unit24, corners: [.topLeft, .topRight])
                        .matchedGeometryEffect(id: "AnimationId.textBackgroundId", in: animation)
                )
            }
        }
        .mask {
            RoundedRectangle(cornerRadius: 0)
                .matchedGeometryEffect(id: "AnimationId.backgroundShapeId", in: animation)
        }
        .onAppear {
            UIScrollView.appearance().bounces = false
            
            withAnimation(.linear) {
                isAppeared = isShowingDetail
            }
            withAnimation(.linear.delay(0.2)) {
                animateText = true
            }
        }
        .onDisappear {
            withAnimation(.linear) {
                animateText = false
            }
        }
        // MARK: - Close Button
        .overlay(
            CloseButton(isShowingDetail: $isShowingDetail)
                .opacity(isAppeared ? 1 : 0)
                .padding(.top, 24)
                .padding(.trailing, 24),
            alignment: .topTrailing
        )
        .statusBarHidden(true)
        .ignoresSafeArea()
    }
}


struct CardDetail_Previews: PreviewProvider {
    struct TestCardDetail: View {
        @Namespace var animation
        var body: some View {
            CardDetail(
                isShowingDetail: .constant(true),
                isAppeared: .constant(true),
                animation: animation
            )
        }
    }
    static var previews: some View {
        TestCardDetail()
    }
}
