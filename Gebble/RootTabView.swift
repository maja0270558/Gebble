//
//  RootTabView.swift
//  MelodifyLyrics
//
//  Created by DjangoLin on 2023/10/19.
//

import SwiftUI

struct RootTabView: View {
    
    var body: some View {
        TabView {
            Group {
                Text("Artists")
                    .tabItem {
                        Image(systemName: "figure.socialdance")
                        Text("Artists")
                    }
                   
                Text("Home")
                    .tabItem {
                        Image(systemName: "house")
                        Text("Home")
                    }
                  
                Text("Account")
                    .tabItem {
                        Image(systemName: "person.circle")
                        Text("Account")
                    }
                  
            }
            .toolbarBackground(Color.base, for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
            .toolbarColorScheme(.light, for: .tabBar)
        }
        .tint(Color.yellow)
    }
}

#Preview {
    RootTabView()
}
