//
//  NavigationBaseView.swift
//  Gebble
//
//  Created by DjangoLin on 2023/11/11.
//

import SwiftUI

struct NavigationBaseView<Content: View>: View {
    private let makeContent: () -> Content

    init(makeContent: @escaping () -> Content) {
        self.makeContent = makeContent
    }
    
    var body: some View {
        ZStack {
            NavigationStack {
                ZStack {
                    // Full detail
                    Color.base.ignoresSafeArea(.all)
                    makeContent()
                }
            }.onAppear {
                let appearance = UINavigationBarAppearance()
                appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
                appearance.backgroundColor = UIColor(Color.base.opacity(0.2))
                UINavigationBar.appearance().scrollEdgeAppearance = appearance
                // Inline appearance (standard height appearance)
                UINavigationBar.appearance().standardAppearance = appearance
                // Large Title appearance
                UINavigationBar.appearance().scrollEdgeAppearance = appearance
            }
        }
    }
}

