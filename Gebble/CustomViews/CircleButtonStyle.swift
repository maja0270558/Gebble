//
//  CircleButtonStyle.swift
//  Gebble
//
//  Created by DjangoLin on 2023/11/9.
//

import SwiftUI

struct CircleButtonStyle: ButtonStyle {
    var imageName: String
    var foreground = Color.black
    var background = Color.base
    var width: CGFloat = 40
    var height: CGFloat = 40

    func makeBody(configuration: Configuration) -> some View {
        Circle()
            .fill(background)
            .overlay(Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .foregroundColor(foreground)
                .padding(12))
            .frame(width: width, height: height)
    }
}
