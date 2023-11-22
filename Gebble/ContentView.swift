//
//  ContentView.swift
//  Gebble
//
//  Created by DjangoLin on 2023/10/23.
//

import Combine
import Popovers
import SwiftUI

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
    ContentView()
}
