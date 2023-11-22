//
//  StateShare.swift
//  Gebble
//
//  Created by DjangoLin on 2023/11/21.
//

import Foundation
import ComposableArchitecture
 import Dependencies

typealias User = String

struct LoginFeature: Reducer {
    struct State: Equatable {
        var userName: String = ""
        var password: String = ""
    }

    enum Action: Equatable {
        case signinButtonTaped
    }

    var body: some ReducerOf<Self> {
        Reduce<State, Action> { _, _ in
            .none
        }
    }
}

struct GlobalStateReducer: Reducer {
    
    struct State: Equatable {
        var user: User?
        var loginViewPresent: Bool = false
    }
    
    enum Action: Equatable {
        case setUser(User)
        case loginViewPresent(Bool)
    }
    
    var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .setUser(let user):
                state.user = user
            case .loginViewPresent(let isPresent):
                state.loginViewPresent = isPresent
            }
            return .none
        }
       
    }
   
}

struct SharedStateStore {
    
    var globalStore: StoreOf<GlobalStateReducer>
    
    func update<T, S, A>
    (
        _ keyPath: KeyPath<Self, T>,
        action: A
    )  where T: Store<S, A>, S: Equatable, A: Equatable
    {
       let store = self[keyPath: keyPath]
       let viewStore = ViewStore(store, observe: { $0 })
       viewStore.send(action)
    }
}

extension Reducer {
    
    func subscribe<S,A,T>
    (
        to store: Store<S, A>,
        keyPath: KeyPath<S, T>,
        action: @escaping (T) -> Action
    )
    -> Effect<Action> where S: Equatable, A: Equatable {
        .run { send in
            let viewStore = ViewStore(store, observe: { $0 })
            let sharedStatePublisher = viewStore.publisher
            for await value in sharedStatePublisher.values.map({ $0[keyPath: keyPath] }) {
                await send(action(value))
            }
        }
        .cancellable(id: keyPath)
    }
 
}

extension SharedStateStore: DependencyKey {
    
    static let liveValue: SharedStateStore = SharedStateStore(globalStore:Store(initialState: GlobalStateReducer.State()) {
        GlobalStateReducer()._printChanges()
    })

    static let mock: SharedStateStore = SharedStateStore(globalStore:Store(initialState: GlobalStateReducer.State(loginViewPresent: true)) {
        GlobalStateReducer()._printChanges()
    })
    
}

extension DependencyValues {

    var sharedState: SharedStateStore {
        get { self[SharedStateStore.self] }
        set { self[SharedStateStore.self] = newValue }
    }
}
