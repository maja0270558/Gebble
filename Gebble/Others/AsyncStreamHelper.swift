//
//  AsyncStreamHelper.swift
//  Gebble
//
//  Created by DjangoLin on 2023/11/7.
//

import Foundation

public func foreachStream<T>
(
    stream: AsyncStream<T>,
    _ fire: (T) async -> Void
) async {
    for await state in stream {
        await fire(state)
    }
}

func convertStringToFlag(_ string: String) -> String {
    let base = 127397
    var tempScalarView = String.UnicodeScalarView()
    for i in string.utf16 {
        if let scalar = UnicodeScalar(base + Int(i)) {
            tempScalarView.append(scalar)
        }
    }
    return String(tempScalarView)
}
