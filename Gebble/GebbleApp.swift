//
//  GebbleApp.swift
//  Gebble
//
//  Created by DjangoLin on 2023/10/23.
//

import SwiftUI
import ComposableArchitecture

@main
struct GebbleApp: App {
    var body: some Scene {
        WindowGroup {
            RootTabView(
                store: Store(
                    initialState: AppFeature.State(),
                    reducer: {
                        AppFeature()
                    }
                )
            )
        }
    }
}
