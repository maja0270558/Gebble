//
//  ArtistClientLive.swift
//  Gebble
//
//  Created by DjangoLin on 2023/10/23.
//

import Foundation
import Dependencies


extension ArtistClient: DependencyKey {
    static let liveValue: Self = .init(
        fetchArtistList: {
            await sendRequest(
                endpoint: ArtistEndpoint.artistList,
                responseModel: ArtistList.self
            )
        },
        fetchArtists: { name in
            await sendRequest(
                endpoint: ArtistEndpoint.artist(name: name),
                responseModel: Artist.self
            )
        }
    )
}

extension ArtistClient: TestDependencyKey {
    static let previewValue: Self = .init(
        fetchArtistList: {
            .success(.init(count: 0, results: [
                ArtistList.ArtistListItem(username: "django",
                                          artistName: "django",
                                          thumb: "",
                                          country: "tw"),
                
                ArtistList.ArtistListItem(username: "kookie",
                                          artistName: "yiu",
                                          thumb: "",
                                          country: "tw"),
                
                ArtistList.ArtistListItem(username: "kookie",
                                          artistName: "funk",
                                          thumb: "",
                                          country: "tw")
            ]))
        },
        fetchArtists: { _ in
            .failure(.invalidURL)
        }
    )
    
    static var testValue: Self = .init(
        fetchArtistList: {
            .success(.init(count: 0, results: []))
        },
        fetchArtists: { _ in
            .failure(.invalidURL)
        }
    )
}

