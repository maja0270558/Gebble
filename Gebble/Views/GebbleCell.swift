//
//  GebbleCell.swift
//  Gebble
//
//  Created by DjangoLin on 2023/11/11.
//

import SwiftUI

struct GebbleCell: View {
    var image: String
    var title: String
    var flag: String
    
    var imageURL: URL? {
        return image.isEmpty ? nil : URL(string: "\(image)")
    }

    var body: some View {
        ZStack {
            Color.base.shadow(radius: 2, x: 1, y: 1)
            VStack(alignment: .leading, spacing: 2) {
                
                GebbleImage(url: image)
                    .aspectRatio(1, contentMode: .fit)
                    .cornerRadius(10)

                HStack {
                    Text("\(title)")
                        .lineLimit(1)
                        .layoutPriority(1)
                    Spacer()
                    Text("\(convertStringToFlag(flag))")
                        .lineLimit(1)
                        .layoutPriority(2)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}



struct GebbleCell_Previews: PreviewProvider {

    static var previews: some View {
        let gridItemLayout = [GridItem(.flexible(), spacing: 8),
                              GridItem(.flexible(), spacing: 8),
                              GridItem(.flexible(), spacing: 8)]
        ScrollView {
            LazyVGrid(columns: gridItemLayout) {
                ForEach(1..<20, id: \.self) { _ in
                    GebbleCell(image: "https://m.media-amazon.com/images/I/81sMEvzsAxL.jpg",
                               title: "title so longasdsad",
                               flag: "US")
                }
            }.padding()
        }
        
    }
}
