//
//  ErrorView.swift
//  Gebble
//
//  Created by DjangoLin on 2023/11/15.
//

import SwiftUI

struct GebbleErrorView: View {
    var title: String
    var body: some View {
        VStack {
            Image("G10").resizable().aspectRatio(contentMode: .fit)
            Text("\(title)")
            Spacer()

        }
    }
}

#Preview {
    GebbleErrorView(title: "some error")
}
