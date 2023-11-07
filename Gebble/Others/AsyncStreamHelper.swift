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
