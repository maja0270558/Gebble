//
//  WorkshopInterface.swift
//  Gebble
//
//  Created by DjangoLin on 2023/11/11.
//

import Foundation
import ComposableArchitecture
import Dependencies

extension WorkshopClient: HTTPClient {}

enum WorkshopEndpoint {
    case allWorkshop
    case search(String, WorkshopFilterValue)
    case detail(String)
}

extension WorkshopEndpoint: Endpoint {
    var query: [URLQueryItem]? {
        switch self {
        case let .search(query, filter):
            print(filter)
            var querys = [URLQueryItem]()
            if filter.thisMonth {
                querys.append(URLQueryItem(name: "this_month", value: "yes"))
            }
            
            if filter.country != .all  {
                querys.append(URLQueryItem(name: "query", value: "\(filter.country.id)"))
            }
            
            if query != "" {
                querys.append(URLQueryItem(name: "workshop_name", value: query))
            }
            
            return querys
        default:
            return nil
        }
    }

    var path: String {
        switch self {
        case .allWorkshop:
            return "workshops/list/"
        case .search:
            return "workshops/search/"
        case let .detail(uuid):
            return "workshops/\(uuid)/"
        }
    }

    var method: RequestMethod {
        return .get
    }

    var header: [String: String]? {
        switch self {
        default:
            return [
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

struct WorkshopFilterValue: Equatable {
    var country: Country
    var thisMonth: Bool
}

struct WorkshopClient {
    var fetchArtistDetail: @Sendable (_ uuid: String) async throws -> WorkshopDetail
    var fetchAllWorkshopList: @Sendable () async throws -> WorkshopList
    var searchWorkshops: @Sendable (_ name: String, _ filter: WorkshopFilterValue) async throws -> [WorkshopList.WorkshopListItem]
}

struct WorkshopList: Decodable, Equatable {
    var count: Int
    var next: String?
    var previous: String?
    var results: [WorkshopListItem]
    var totalPages: Int
    
    struct WorkshopListItem: Decodable, Equatable {
        var id: Int
        var uuid: String
        var username: String
        var category: Int
        var teacher1: String
        var poster: String
        var title: String
        var country: String
        var created: Date?
        var modified: Date?
    }
}

extension WorkshopList.WorkshopListItem {
    static var placeholder: [WorkshopList.WorkshopListItem] {
        var placeholder = [WorkshopList.WorkshopListItem]()
        for i in 0 ... 20 {
            placeholder.append(.init(id: i,
                                     uuid: "uuid",
                                     username: "placeholder",
                                     category: 0,
                                     teacher1: "",
                                     poster: "",
                                     title: "",
                                     country: "US"))
        }
        return placeholder
    }
}

struct WorkshopDetail: Decodable, Equatable {
    var id: Int
    var uuid: String
    var uniqueurl: String
    var title: String
    var username: String
    var category: Int
    var poster: String
    var startDate: String
    var dateTime: Date
    var country: String
    var venue: String
    var content: String
    var iglink: String
    var videolink: String
    var contactEmail: String
    var teacher1: String
    var name1: String
    var photo1: String
    var videolink1: String
    var country1: String
    var info1: String
    var event: String?
    var profilePhoto: String
    var created: Date
    var modified: Data
}
