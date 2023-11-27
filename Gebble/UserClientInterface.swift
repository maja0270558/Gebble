//
//  UserClient.swift
//  Gebble
//
//  Created by DjangoLin on 2023/11/23.
//

import Foundation

extension UserClient: HTTPClient {}

enum UserEndpoint {
  
}

extension UserEndpoint: Endpoint {
    var query: [URLQueryItem]? {
        switch self {
     
        default:
            return nil
        }
    }

    var path: String {
        switch self {
        
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

struct UserClient {
    
}
