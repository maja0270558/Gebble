//
//  WorkshopLive.swift
//  Gebble
//
//  Created by DjangoLin on 2023/11/11.
//

import Foundation
import Dependencies
import ComposableArchitecture

extension DependencyValues {
    var workshopClient: WorkshopClient {
        get { self[WorkshopClient.self] }
        set { self[WorkshopClient.self] = newValue }
    }
}

extension WorkshopClient: DependencyKey {
    static let liveValue: Self = .init(
        fetchAllWorkshopList: {
            try await sendRequest(
                endpoint: WorkshopEndpoint.allWorkshop,
                responseModel: WorkshopList.self
            )
        },
        searchWorkshops: { querry in
            unimplemented("searchWorkshop")
        }
    )
}

extension WorkshopClient: TestDependencyKey {
    
}

