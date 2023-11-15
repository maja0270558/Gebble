//
//  GebbleImageCell.swift
//  Gebble
//
//  Created by DjangoLin on 2023/11/11.
//

import Kingfisher
import SwiftUI

struct GebbleImageCell: View {
    var image: String
    var title: String
    var flag: String

    var imageURL: URL? {
        return image.isEmpty ? nil : URL(string: "\(image)")
    }

    var body: some View {
        ZStack {
            VStack {
                
                GeometryReader { proxy in
                    KFImage(imageURL)
                        .placeholder {
                            Image(systemName: "person")
                                .resizable()
                                .redacted(reason: .placeholder)
                        }
                        .scaledToFit()
                        .frame(width: proxy.size.width)
                        .frame(width: proxy.size.width, height: proxy.size.height)

                }
            }

            LinearGradient(colors: [.clear, .clear, .black.opacity(0.7)], startPoint: .top, endPoint: .bottom)

            VStack {
                Spacer()
                HStack(alignment: .bottom, spacing: 0) {
                    Text("\(title)")
                        .bold()
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .layoutPriority(1)
                    Spacer()
                    Text("\(convertStringToFlag(flag))")
                        .lineLimit(1)
                        .layoutPriority(2)
                }
                .padding(6)
            }
        }
        .aspectRatio(1, contentMode: .fill)
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

struct GebbleImageCell_Previews: PreviewProvider {
    static var previews: some View {
        let gridItemLayout = [GridItem(.flexible(), spacing: 2),
                              GridItem(.flexible(), spacing: 2)]
        ScrollView {
            LazyVGrid(columns: gridItemLayout, spacing: 2) {
                ForEach(1 ..< 20, id: \.self) { _ in
                    GebbleImageCell(image: "https://mediumthumb-event-photos.s3.amazonaws.com/3c4490d7-b572-4a1f-b98d-61e58cd6c8cb.png",
                                    title: "title so long title so long title so long",
                                    flag: "US")
                }
            }.padding()
        }
    }
}
