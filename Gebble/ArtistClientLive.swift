//
//  ArtistClientLive.swift
//  Gebble
//
//  Created by DjangoLin on 2023/10/23.
//

import Foundation

extension ArtistClient: HTTPClient {
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

    static let mockValue: Self = .init(
        fetchArtistList: {
            .success(.init(count: 0, results: []))
        },
        fetchArtists: { _ in
            .failure(.invalidURL)
        }
    )
}
