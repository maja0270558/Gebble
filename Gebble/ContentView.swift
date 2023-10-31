//
//  ContentView.swift
//  Gebble
//
//  Created by DjangoLin on 2023/10/23.
//

import SwiftUI
import Combine

struct ContentView: View {
    init() {
    
    }
    
    var body: some View {
        VStack {
            
            
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
                .onTapGesture {
                }
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
