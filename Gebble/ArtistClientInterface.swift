//
//  ArtistClient.swift
//  Gebble
//
//  Created by DjangoLin on 2023/10/23.
//

import Foundation
import Combine

enum ArtistEndpoint {
    case artistList
    case artist(name: String)
}

extension ArtistEndpoint: Endpoint {
    var path: String {
        switch self {
        case .artistList:
            return "/artist/portfolios/list/"
        case .artist(let name):
            return "/artist/portfolios/\(name)"
        }
    }

    var method: RequestMethod {
        return .get
    }

    var header: [String: String]? {
        // Access Token to use in Bearer header
        let accessToken = "insert your access token here -> https://www.themoviedb.org/settings/api"
        switch self {
        case .artistList, .artist:
            return [
                "Authorization": "Bearer \(accessToken)",
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
    var fetchArtistList: @Sendable () async -> Result<String, RequestError>
    var fetchArtists: @Sendable (_ name: String) async -> Result<String, RequestError>
}


extension ArtistClient: HTTPClient {
    static let liveValue: Self = .init(
        fetchArtistList: {
            await sendRequest(endpoint: ArtistEndpoint.artistList, responseModel: String.self)
        },
        fetchArtists: { name in
            await sendRequest(endpoint: ArtistEndpoint.artist(name: name), responseModel: String.self)
        }
    )
    
    static let mockValue: Self = .init(
        fetchArtistList: {
            .success("")
        },
        fetchArtists: { name in
            .failure(.invalidURL)
        }
    )
}
