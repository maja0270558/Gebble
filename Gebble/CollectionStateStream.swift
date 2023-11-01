//
//  CollectionStateStream.swift
//  Gebble
//
//  Created by DjangoLin on 2023/11/1.
//

import Foundation
import ComposableArchitecture

// MARK: - Dependency

extension DependencyValues {
    var collectionStateStreamMaker: CollectionStateStream {
        get { self[CollectionStateStream.self] }
        set { self[CollectionStateStream.self] = newValue }
    }
}

struct CollectionStateStream {
    var maker: CollectionStateStreamMaker
}

extension CollectionStateStream: DependencyKey {
    static let liveValue: CollectionStateStream = .init(maker: LivePlaceholderMaker())
}

extension CollectionStateStream: TestDependencyKey {
    static let placeholderValue: CollectionStateStream = .init(maker: PreviewPlaceholderMaker())
}

// MARK: - Maker

protocol CollectionStateStreamMaker {
    func asyncStreamState<T: Collection>
    (
        placeholder: T,
        body: @Sendable @escaping () async throws -> T
    ) async -> AsyncStream<CollectionLoadingState<T>>
}

struct PreviewPlaceholderMaker: CollectionStateStreamMaker {
    func asyncStreamState<T: Collection>
    (
        placeholder: T,
        body: @Sendable @escaping () async throws -> T
    ) async -> AsyncStream<CollectionLoadingState<T>> {
        let stream = AsyncStream(CollectionLoadingState<T>.self) { continuation in
            Task {
                continuation.yield(.loading(placeholder: placeholder))
                continuation.finish()
            }
        }

        return stream
    }
}

struct LivePlaceholderMaker: CollectionStateStreamMaker {
    func asyncStreamState<T: Collection>
    (
        placeholder: T,
        body: @Sendable @escaping () async throws -> T
    ) async -> AsyncStream<CollectionLoadingState<T>> {
        let stream = AsyncStream(CollectionLoadingState<T>.self) { continuation in
            Task {
                continuation.yield(.loading(placeholder: placeholder))

                let response = await TaskResult {
                    try await body()
                }

                switch response {
                case let .success(data):
                    continuation.yield(data.isEmpty ? .empty : .loaded(content: data))
                case let .failure(error):
                    continuation.yield(.error(error))
                }
                continuation.finish()
            }
        }

        return stream
    }
}
