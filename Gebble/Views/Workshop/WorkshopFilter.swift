//
//  WorkshopFilter.swift
//  Gebble
//
//  Created by DjangoLin on 2023/11/15.
//

import ComposableArchitecture
import SwiftUI

struct WorkshopFilterFeature: Reducer {
    struct State: Equatable {
        @BindingState var filter: WorkshopFilterValue
    }
    
    enum Action:BindableAction, Equatable {
        case binding(BindingAction<State>)
        case delegate(Delegate)
    }
    
    enum Delegate: Equatable {
        case onApplyClick
        case onResetClick
        case onCloseClick
        case onCountryClick(Country)
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { _, _ in
                .none
        }
    }
}

struct WorkshopFilter: View {
    let store: StoreOf<WorkshopFilterFeature>
    static let initFilter: WorkshopFilterValue = .init(country: .all, thisMonth: false)

    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            ZStack {
                Color.base.ignoresSafeArea()
                VStack(alignment: .center) {
                    HStack {
                        Image(systemName: "xmark")
                            .onTapGesture {
                                viewStore.send(.delegate(.onCloseClick))
                            }
                        Spacer()
                        Text("Filter").bold()
                        Spacer()
                    }
                    .padding()
                    
                    Divider()
                    
                    VStack {
                        HStack {
                            VStack(alignment: .leading) {
                                Label {
                                    Text("Country").bold()
                                } icon: {
                                    Image(systemName: "globe.europe.africa")
                                }
                                Text("Filter workshop region")
                            }
                            Spacer()
                            
                            Menu {
                                
                                Button {
                                    viewStore.send(.delegate(.onCountryClick(.all)))
                                } label: {
                                    HStack {
                                        Text("All")
                                        
                                        if viewStore.filter.country == .all {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                                
                                
                                Picker(selection: viewStore.$filter.country) {
                                    ForEach(countryList, id: \.self) { option in
                                        Text(option.name)
                                    }
                                } label: {
                                    HStack {
                                        Button(action: {}) {
                                            Text("Country")
                                            if viewStore.filter.country != .all {
                                                Text(viewStore.filter.country.name)
                                            }
                                        }
                                        if viewStore.filter.country != .all {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                                .pickerStyle(.menu)
                                
                            } label: {
                                Text("\(viewStore.filter.country.name)")
                            }
                            .menuOrder(.fixed)
                            
                        }.tint(Color.searchGray)
                        
                        Toggle(isOn: viewStore.$filter.thisMonth) {
                            VStack(alignment: .leading) {
                                Label {
                                    Text("This month only").bold()
                                } icon: {
                                    Image(systemName: "calendar")
                                }
                                Text("Filter workshop this month")
                            }
                        }
                        .tint(Color.brown)
                        
                        Spacer()
                        
                        HStack {
                            Button {
                                viewStore.send(.delegate(.onResetClick))
                            } label: {
                                Text("Reset")
                                    .underline()
                                    .tint(Color.black)
                                    .frame(maxWidth: .infinity)
                            }
                            
                            Button {
                                viewStore.send(.delegate(.onApplyClick))
                            } label: {
                                Text("Apply")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(Color.brown)
                        }
                        
                    }.padding()
                    Spacer()
                }
            }
            .presentationDetents([.height(250)])
        }
    }
}

#Preview {
    WorkshopFilter(store: Store(initialState: WorkshopFilterFeature.State(filter: .init(country: .all, thisMonth: false)),
                                reducer: {
                                    WorkshopFilterFeature()
                                }))
}
