//
//  AccountView.swift
//  Gebble
//
//  Created by DjangoLin on 2023/11/22.
//

import ComposableArchitecture
import SwiftUI

struct AccountFeature: Reducer {
    struct State: Equatable {}

    enum Action: Equatable {}

    var body: some ReducerOf<Self> {
        Reduce { _, _ in
            .none
        }
    }
}

struct AccountView: View {
    let store: StoreOf<AccountFeature>
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { _ in
            NavigationBaseView {
                VStack {
                    Image(systemName: "bell")
                    Form(content: {
                        Section(header: Text("Profile")) {
                            HStack(alignment: .center) {
                                Image("p")
                                    .resizable()
                                    .aspectRatio(1, contentMode: .fit)
                                    .frame(height: 70)
                                    .clipShape(Circle())
                                    
                                Text("JohnDoe")
                                    .bold()
                                Spacer()
                                Image(systemName: "pencil")
                            }
                            // Add more user details as needed
                        }
                        .listRowBackground(Color.white)

                        Section(header: Text("Your")) {
                            NavigationLink {
                                
                            } label: {
                                HStack {
                                    Image(systemName: "gearshape")
                                    Text("Journey")
                                }
                            }

                            NavigationLink {
                                
                            } label: {
                                HStack {
                                    Image(systemName: "heart")
                                    Text("Mettion")
                                }
                            }
                            
                            NavigationLink {
                                
                            } label: {
                                HStack {
                                    Image(systemName: "questionmark.circle")
                                    Text("Workshop")
                                }
                            }
                            
                        }
                        .listRowBackground(Color.white)
                        
                        // Settings options section
                        Section(header: Text("Settings")) {
                            NavigationLink {
                                
                            } label: {
                                HStack {
                                    Image(systemName: "gearshape")
                                    Text("Setting")
                                }
                            }

                            NavigationLink {
                                
                            } label: {
                                HStack {
                                    Image(systemName: "questionmark.circle")
                                    Text("Help")
                                }
                            }
                            
                        }
                        .listRowBackground(Color.white)
                        
                        // Logout button
                        Button(action: {
                            // Add logout functionality
                        }) {
                            Text("Log Out")
                                .foregroundColor(.red)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .frame(height: 30)

                    })
                   
                }
                .scrollContentBackground(.hidden)
                .navigationTitle("Profile")
            }
        }
    }
}

#Preview {
    AccountView(store:
        Store(initialState: AccountFeature.State(), reducer: {
            AccountFeature()
        })
    )
}
