//
//  ArtistClient.swift
//  Gebble
//
//  Created by DjangoLin on 2023/10/23.
//

import Combine
import Foundation

enum ArtistEndpoint {
    case artistList
    case artist(name: String)
}

extension ArtistEndpoint: Endpoint {
    var path: String {
        switch self {
        case .artistList:
            return "artist/portfolios/list/"
        case .artist(let name):
            return "artist/portfolios/\(name)"
        }
    }

    var method: RequestMethod {
        return .get
    }

    var header: [String: String]? {
        // Access Token to use in Bearer header
//        let sometoken = "insert your access token here"
        switch self {
        case .artistList, .artist:
            return [
                //                "Authorization": "Bearer \(accessToken)",
                "Content-Type": "application/json;charset=utf-8"
            ]
        }
    }

    var body: [String: String]? {
        switch self {
        case .artistList, .artist:
            return nil
        }
    }
}

struct ArtistClient {
    var fetchArtistList: @Sendable () async -> Result<ArtistList, RequestError>
    var fetchArtists: @Sendable (_ name: String) async -> Result<Artist, RequestError>
}

extension ArtistClient: HTTPClient {
    static let liveValue: Self = .init(
        fetchArtistList: {
            await sendRequest(endpoint: ArtistEndpoint.artistList, responseModel: ArtistList.self)
        },
        fetchArtists: { name in
            await sendRequest(endpoint: ArtistEndpoint.artist(name: name), responseModel: Artist.self)
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

// ArtistList
struct ArtistList: Decodable {
    var count: Int
    var next: String?
    var previous: String?
    var results: [ArtistListItem]

    struct ArtistListItem: Decodable {
        var username: String
        var artistName: String
        var thumb: String
        var country: String
    }
}

// Artist
struct Artist: Decodable {
    var username: String
    var profilePhoto: String
    var artistName: String
    var cover: String
    var thumb: String
    var country: String
    var introduction: String
    var modified: Date
}
