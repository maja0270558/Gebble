//
//  GebbleSearchBar.swift
//  Gebble
//
//  Created by DjangoLin on 2023/11/14.
//

import ComposableArchitecture
import SwiftUI

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

struct GebbleSearchBarFeature: Reducer {
    struct State: Equatable {
        var queryString: String
        var containFilterValue: Bool = false
        @BindingState var isFocused: Bool
    }

    enum Action: BindableAction, Equatable {
        case delegate(Delegate)
        case binding(BindingAction<State>)
    }
    
    enum Delegate: Equatable {
        case onCleanQueryClick
        case onFilterClick
        case onQueryChange(String)
    }

    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
           .none
        }
    }
}

struct GebbleSearchBar: View {
    let store: StoreOf<GebbleSearchBarFeature>
    var prompt: String
    var filter: Bool
    @FocusState var isFocused: Bool

    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            HStack {
                Group {
                    HStack(spacing: 0) {
                        Image(systemName: "magnifyingglass")

                        TextField("\(prompt)",
                                  text: viewStore.binding(
                                      get: \.queryString,
                                      send: {
                                          .delegate(.onQueryChange($0))
                                      })
                                      .animation(.easeInOut))
                            .focused($isFocused)
                            .padding(.horizontal)
                            .disableAutocorrection(true)
                            .bind(viewStore.$isFocused.animation(.smooth), to: self.$isFocused)

                        if filter {
                            Button {
                                viewStore.send(.delegate(.onFilterClick))
                            } label: {
                                Image(systemName: "line.3.horizontal.decrease.circle")
                            }
                            .foregroundColor(viewStore.containFilterValue ? Color.brown : Color.searchGray)
                        }

                        Spacer()
                    }
                }
                .padding(12)
            }
            .foregroundStyle(Color.searchGray)
            .background(Color.white)
            .cornerRadius(12)
            .padding(.trailing, viewStore.queryString.isEmpty ? 0 : 30)
            .overlay {
                if !viewStore.queryString.isEmpty {
                    HStack {
                        Spacer()
                        Button {
                            viewStore.send(.delegate(.onCleanQueryClick), animation: .easeInOut)
                        } label: {
                            Image(systemName: "multiply.circle.fill")
                        }
                        .foregroundColor(Color.searchGray)
                    }
                }
            }
        }
    }
}
