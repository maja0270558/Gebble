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
        fetchArtistsPortfolios: { name in
            try await sendRequest(
                endpoint: ArtistEndpoint.artistPortfolios(name: name),
                responseModel: ArtistPortfolios.self
            )
        },
        fetchArtistsBio: { name in
            try await sendRequest(
                endpoint: ArtistEndpoint.artistBios(name: name),
                responseModel: ArtistBio.self
            )
        },
        searchArtists: { query in
            try await sendRequest(
                endpoint: ArtistEndpoint.searchArtists(query: query),
                responseModel: [ArtistList.ArtistListItem].self
            )
        }
    )
}

extension ArtistClient: TestDependencyKey {
    
    static let fakeValue: Self = .init(
        fetchArtistList: {
            return .init(count: 0, results: [
                .init(username: "a", artistName: "aa", thumb: "aaa", country: "aaaa"),
                .init(username: "a1", artistName: "aa1", thumb: "aaa1", country: "aaaa1"),
                .init(username: "a2", artistName: "aa2", thumb: "aaa2", country: "aaaa2")
            ])
        },
        fetchArtistsPortfolios: { _ in
            unimplemented("fetch arrtist")
        },
        fetchArtistsBio: { _ in
            unimplemented("fetch arrtist")
        },
        searchArtists: { query in
            return [
                .init(username: "a", artistName: "aa", thumb: "aaa", country: "aaaa"),
                .init(username: "a1", artistName: "aa1", thumb: "aaa1", country: "aaaa1"),
                .init(username: "a2", artistName: "aa2", thumb: "aaa2", country: "aaaa2")
            ]
        }
    )
    
    static let emptyValue: Self = .init(
        fetchArtistList: {
            return .init(count: 0, results: [])
        },
        fetchArtistsPortfolios: { _ in
            unimplemented("fetch arrtist")
        },
        fetchArtistsBio: { _ in
            unimplemented("fetch arrtist")
        },
        searchArtists: { _ in
           return []
        }
    )
    
    static let errorValue: Self = .init(
        fetchArtistList: {
            throw RequestError.noResponse
        },
        fetchArtistsPortfolios: { _ in
            unimplemented("fetch arrtist")
        },
        fetchArtistsBio: { _ in
            unimplemented("fetch arrtist")
        },
        searchArtists: { _ in
            unimplemented("searchArtists")
        }
    )
    
    static let testValue: Self = .init(
        fetchArtistList: {
            unimplemented("test fetchArtistList")
        },
        fetchArtistsPortfolios: { _ in
            unimplemented("fetch arrtist")
        },
        fetchArtistsBio: { _ in
            unimplemented("fetch arrtist")
        },
        searchArtists: { _ in
            unimplemented("searchArtists")
        }
    )
}

