//
//  ArtistClientLive.swift
//  Gebble
//
//  Created by DjangoLin on 2023/10/23.
//

import Foundation
import Dependencies
import ComposableArchitecture

extension ArtistClient: DependencyKey {
    static let liveValue: Self = .init(
        fetchArtistList: {
            try await sendRequest(
                endpoint: ArtistEndpoint.artistList,
                responseModel: ArtistList.self
            )
        },
        fetchArtists: { name in
            try await sendRequest(
                endpoint: ArtistEndpoint.artist(name: name),
                responseModel: Artist.self
            )
        }
    )
}

extension ArtistClient: TestDependencyKey {
    
    static let emptyValue: Self = .init(
        fetchArtistList: {
            return .init(count: 0, results: [])
        },
        fetchArtists: { _ in
            unimplemented("fetch arrtist")
        }
    )
    
    static let errorValue: Self = .init(
        fetchArtistList: {
            throw RequestError.noResponse
        },
        fetchArtists: { _ in
            unimplemented("fetch arrtist")
        }
    )
    
    static let testValue: Self = .init(
        fetchArtistList: {
            unimplemented("test fetchArtistList")
        },
        fetchArtists: { _ in
            unimplemented("test fetchArtist")
        }
    )
}

