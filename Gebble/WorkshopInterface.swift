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
