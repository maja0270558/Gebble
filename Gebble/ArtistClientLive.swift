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
                                          thumb: "https://minithumb-cover-photos.s3.amazonaws.com/085c33a0-8863-4eb2-ae1e-da9ca6681456.png",
                                          country: "AF"),
                
                ArtistList.ArtistListItem(username: "kookie",
                                          artistName: "kookie",
                                          thumb: "https://minithumb-cover-photos.s3.amazonaws.com/04faceba-9e1a-49d4-954f-f015ac4e3f8a.png",
                                          country: "NP"),
                
                ArtistList.ArtistListItem(username: "yiyasha",
                                          artistName: "yiyasha",
                                          thumb: "https://minithumb-cover-photos.s3.amazonaws.com/90bac745-6350-4a4f-b181-938326c3c1a0.png",
                                          country: "US")
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

