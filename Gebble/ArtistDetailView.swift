//
//  ArtistDetailView.swift
//  Gebble
//
//  Created by DjangoLin on 2023/11/7.
//

import ScalingHeaderScrollView
import ComposableArchitecture
import SwiftUI


struct ArtistDetailView: View {
    // 2 api get bio, profolio
    private let minHeight = 150.0
    private let maxHeight = UIScreen.main.bounds.height / 2
    @State var progress: CGFloat = 0
    
    enum Tabs:Int {
        case about, journey, e1t1
        
        var  title:  String {
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
    let types: [Tabs] = [.about, .journey, .e1t1]
    @State var currentType: Int = Tabs.about.rawValue

    @Namespace var animation
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color.base.ignoresSafeArea()

            ScalingHeaderScrollView {
                largeHeader
                    .opacity(1 - progress)

            } content: {
                profilerContentView.zIndex(progress == 1 ? 0 : 2).frame(width: UIScreen.main.bounds.width)
                    .gesture(DragGesture(minimumDistance: 20, coordinateSpace: .global)
                                .onEnded { value in
                                    guard abs(value.velocity.width) > 500 else { return }
                                    let horizontalAmount = value.translation.width
                                    let verticalAmount = value.translation.height
                                    
                                    if abs(horizontalAmount) > abs(verticalAmount) {
                                        withAnimation(.easeInOut) {
                                            if horizontalAmount < 0 {
                                                print("left swipe")
                                                currentType = min(types.count - 1, currentType + 1)
                                            } else {
                                                currentType = max(0, currentType - 1)
                                                print("right swipe")
                                            }
                                        }
                                    }
                                })
                
               
                

            }
            .height(min: minHeight, max: maxHeight)
            .collapseProgress($progress)
            .allowsHeaderCollapse()
            .ignoresSafeArea()
            
            navgationBar
                .opacity(max(0, min(1, (progress - 0.75) * 4.0)))
            topButtons.onTapGesture {
                dismiss()
            }
            
            
    
        }
    }

    private var largeHeader: some View {
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
                PinnedHeaderView(id: "Large")
            }
            .padding(.bottom, 20)
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var topButtons: some View {
        VStack {
            HStack {
                Button("", action: { })
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
            PinnedHeaderView(id: "small")
                .background(Color.base)

            Spacer()
        }
    }

    @ViewBuilder
    func PinnedHeaderView(id: String) -> some View {
        VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 25) {
                    ForEach(types, id: \.self) { type in
                        VStack(spacing: 12) {
                            Text(type.title)
                                .fontWeight(.semibold)
                                .foregroundColor(currentType == type.rawValue ? .brown : .gray)

                            ZStack {
                                if currentType == type.rawValue {
                                    Capsule()
                                        .fill(.brown)
                                        .matchedGeometryEffect(id: "TAB\(id)", in: animation)
                                }
                                else {
                                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                                        .fill(.clear)
                                }
                            }
                            .padding(.horizontal, 8)
                            .frame(height: 4)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.easeInOut) {
                                currentType = type.rawValue
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .frame(height: 47.0)
            }
        }
    }

    private var profilerContentView: some View {
        VStack {
            HStack {
                VStack {
                    if currentType == 0 {
                        description
                    } else if currentType == 1 {
                        userName
                    } else  {
                        address
                    }

                }
                .frame(maxWidth: .infinity)
                .padding(24)
            }
            .frame(minHeight: UIScreen.main.bounds.height - maxHeight)
        }
        .background(Color.blue)
        .mask(Rectangle().cornerRadius(12, corners: [.topLeft, .topRight])).offset(y: -10)
    }



    private var userName: some View {
        Text("User name")
    }


    private var address: some View {
        Text("address")

    }


    private var description: some View {
        return VStack {
            Text("descdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdesc")
            Text("descdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdesc")
            Text("descdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdesc")
            Text("descdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdesc")
            Text("descdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdesc")
            Text("descdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdescdesc")
        }
    }

}

#Preview {
    ArtistDetailView()
}
