//
//  PopoverClient.swift
//  Gebble
//
//  Created by DjangoLin on 2023/11/21.
//

import Combine
import ComposableArchitecture
import Foundation

extension DependencyValues {
    var popoverClient: PopoverClient {
        get { self[PopoverClient.self] }
        set { self[PopoverClient.self] = newValue }
    }
}

enum PopoverType: Equatable {
    case error
    case login
    case message
}

typealias PopoverValue = PopoverType?

struct PopoverClient: Sendable {
    var setValue: @Sendable (PopoverValue) -> Void
    var values: @Sendable () -> AsyncStream<PopoverValue>

    init(
        setValue: @Sendable @escaping (PopoverValue) -> Void,
        values: @Sendable @escaping () -> AsyncStream<PopoverValue>
    ) {
        self.setValue = setValue
        self.values = values
    }
}

extension PopoverClient: DependencyKey {
    static let liveValue: PopoverClient = {
        let subject = LockIsolated<CurrentValueSubject<PopoverValue, Never>>(.init(nil))

        return .init(
            setValue: { value in
                subject.withValue { $0.send(value) }
            },
            values: {
                AsyncStream { continuation in
                    subject.withValue {
                        let cancellable = $0
                            .removeDuplicates()
                            .sink { value in
                                continuation.yield(value)
                            }

                        continuation.onTermination = { [cancellable = UncheckedSendable(cancellable)] _ in
                            cancellable.value.cancel()
                        }
                    }
                }
            }
        )
    }()
}
