//
//  GebbleImage.swift
//  Gebble
//
//  Created by DjangoLin on 2023/11/22.
//

import SwiftUI
import NukeUI

struct GebbleImage: View {
    var url: String?
    var body: some View {
        LazyImage(url: URL(string: "\(url ?? "")")) { state in
            if let image = state.image {
                image.resizable()
            } else if state.error != nil {
                Color.gray.opacity(0.4).shimmering().redacted(reason: .placeholder)
            } else {
                Color.gray.opacity(0.4).shimmering().redacted(reason: .placeholder)
            }
        }
        .transition(.opacity)
    }
}

#Preview {
    GebbleImage()
}
