//
//  ArtistsView.swift
//  Gebble
//
//  Created by DjangoLin on 2023/10/24.
//

import SwiftUI

struct CardView: View {
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()
            Image(systemName: "person")
                .resizable()
                .aspectRatio(1,contentMode: .fit)
            
            HStack {
                Text("artistName")
                    .dynamicTypeSize(.small)
                    .lineLimit(1)
                    .frame(height: 20)
                Spacer()
                Image(systemName: "flag")
                    .aspectRatio(contentMode: .fit)
            }
            
        }
        .padding(5)
        .background(Color.base)
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(.gray, lineWidth: 0.2)
        )
       
    }
}


struct ArtistsView: View {
    @State private var searchText = ""
    private var gridItemLayout = [GridItem(.flexible()),
                                  GridItem(.flexible()),
                                  GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    Divider()
                        .padding(.bottom)
                    Text("Explore artist")
                        .font(.headline)
                    Text("Some thing  blablabla.Some thing  blablabla.Some thing  blablabla.Some thing")
                    LazyVGrid(columns: gridItemLayout, content: {
                        
                      
                        ForEach(0 ... 9999, id: \.self) { _ in
                            CardView()
                        }
                    })
                }
            }
            .navigationTitle("Artists")
            .padding()
            .background(Color.base)
        }
        .searchable(text: $searchText, prompt: "Search for artist")
        .tint(Color.black)
    }
}

#Preview {
    ArtistsView()
}
