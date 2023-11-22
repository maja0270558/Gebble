//
//  View+If.swift
//  Gebble
//
//  Created by DjangoLin on 2023/11/7.
//

import Foundation
import SwiftUI

extension View {
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder func `if`<Content: View>(_ condition: @autoclosure () -> Bool, transform: (Self) -> Content) -> some View {
        if condition() {
            transform(self)
        } else {
            self
        }
    }
    
    @ViewBuilder func placeholder(_ condition: @autoclosure () -> Bool) -> some View {
        if condition() {
            self.redacted(reason: .placeholder)
        } else {
            self
        }
    }
    
    @ViewBuilder func placeholder(_ condition: @autoclosure () -> Bool, content: () -> some View) -> some View {
        if condition() {
            content()
        } else {
            self
        }
    }
}

extension Text {
    @ViewBuilder
    static func textPlaceholder() -> some View {
        HStack {
            VStack {
                ForEach(1..<100) { value in
                    Text("\(UUID().uuidString)").redacted(reason: .placeholder).shimmering()
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity)
        }
    }
}
