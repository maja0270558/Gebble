//
//  ArtistClient.swift
//  Gebble
//
//  Created by DjangoLin on 2023/10/23.
//

import Combine
import Foundation
import Dependencies
import ComposableArchitecture

// TODO: change response to effect
// TODO: using TaskResult

// MARK: - Endpoint
extension ArtistClient: HTTPClient {}

extension DependencyValues {
    var artistsClient: ArtistClient {
        get { self[ArtistClient.self] }
        set { self[ArtistClient.self] = newValue }
    }
}

enum ArtistEndpoint {
    case artistList
    case artistPortfolios(name: String)
    case artistBios(name: String)
    case searchArtists(query: String)
}

extension ArtistEndpoint: Endpoint {
    var query: [URLQueryItem]? {
        switch self {
        case let .searchArtists(query: query):
            return [URLQueryItem(name: "query", value: "\(query)")]
        default:
            return nil
        }
    }
    
    var path: String {
        switch self {
        case .artistList:
            return "artist/portfolios/list/"
        case .artistPortfolios(let name):
            return "artist/portfolios/\(name)"
        case .artistBios(let name):
            return "artist/bios/\(name)"
        case .searchArtists:
            return "artist/search/"
        }
    }

    var method: RequestMethod {
        return .get
    }

    var header: [String: String]? {
        // Access Token to use in Bearer header
//        let sometoken = "insert your access token here"
        switch self {
        default:
            return [
                //                "Authorization": "Bearer \(accessToken)",
                "Content-Type": "application/json;charset=utf-8"
            ]
        }
    }

    var body: [String: String]? {
        switch self {
        default:
            return nil
        }
    }
}

// MARK: - Client Interface

struct ArtistClient {
    var fetchArtistList: @Sendable () async throws -> ArtistList
    var fetchArtistsPortfolios: @Sendable (_ name: String) async throws -> ArtistPortfolios
    var fetchArtistsBio: @Sendable (_ name: String) async throws -> ArtistBio
    var searchArtists: @Sendable (_ query: String) async throws -> [ArtistList.ArtistListItem]
}

// MARK: - Model

struct ArtistList: Decodable, Equatable {
    var count: Int
    var next: String?
    var previous: String?
    var results: [ArtistListItem]
    
    struct ArtistListItem: Decodable, Equatable {
        var username: String
        var artistName: String
        var thumb: String
        var country: String
        
        func countryFlag() -> String {
          let base = 127397
          var tempScalarView = String.UnicodeScalarView()
          for i in country.utf16 {
            if let scalar = UnicodeScalar(base + Int(i)) {
              tempScalarView.append(scalar)
            }
          }
          return String(tempScalarView)
        }
    }
}

extension ArtistList.ArtistListItem {
    static var placeholder: [ArtistList.ArtistListItem] {
        var placeholder = [ArtistList.ArtistListItem]()
        for i in 0...20 {
            placeholder.append(.init(username: "\(i)",
                                     artistName: "\(i) this is fake data",
                                     thumb: "",
                                     country: "US"))
        }
        return placeholder
    }
}

struct ArtistPortfolios: Decodable, Equatable {
    var username: String
    var profilePhoto: String
    var artistName: String
    var cover: String
    var thumb: String
    var country: String
    var introduction: String
    var modified: Date
    
    func countryFlag() -> String {
      let base = 127397
      var tempScalarView = String.UnicodeScalarView()
      for i in country.utf16 {
        if let scalar = UnicodeScalar(base + Int(i)) {
          tempScalarView.append(scalar)
        }
      }
      return String(tempScalarView)
    }
}

struct ArtistBio: Decodable, Equatable {
    var username: String
    var style: String?
    var quote: String?
    var crew: String?
    var ig: String?
    var fb: String?
    var yt: String?
    var site: String?
    var gallery1: String?
    var gallery2: String?
    var gallery3: String?
    var gallery4: String?
    var vid1: String?
    var vid2: String?
    var vid3: String?
    var vid4: String?
    var workEmail: String?
    var created: Date?
    var modified: Date?
}
