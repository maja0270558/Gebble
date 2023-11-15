//
//  GebbleEmptyView.swift
//  Gebble
//
//  Created by DjangoLin on 2023/11/15.
//

import SwiftUI

struct GebbleEmptyView: View {
    var title: String
    var body: some View {
        VStack {
            Image("G_yoga2").resizable().aspectRatio(contentMode: .fit)
            Text("\(title)").bold()
            Spacer()
        }
    }
}

#Preview {
    GebbleEmptyView(title: "Empty here")
}
