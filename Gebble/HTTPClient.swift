//
//  HTTPClientInterface.swift
//  Gebble
//
//  Created by DjangoLin on 2023/10/23.
//

import Foundation

enum RequestError: Error {
    case decode
    case invalidURL
    case noResponse
    case unauthorized
    case unexpectedStatusCode
    case unknown

    var customMessage: String {
        switch self {
        case .decode:
            return "Decode error"
        case .unauthorized:
            return "Session expired"
        default:
            return "Unknown error"
        }
    }
}

enum RequestMethod: String {
    case delete = "DELETE"
    case get = "GET"
    case patch = "PATCH"
    case post = "POST"
    case put = "PUT"
}

enum Host: String {
    case dev = "sdjpkww4h3.execute-api.us-east-1.amazonaws.com"
    case production = "hejeu19jod.execute-api.us-east-1.amazonaws.com"

    var envPath: String {
        switch self {
        case .dev:
            return "/dev/api/"
        case .production:
            return "/prod/api/"
        }
    }
}

protocol Endpoint {
    var scheme: String { get }
    var host: Host { get }
    var path: String { get }
    var method: RequestMethod { get }
    var header: [String: String]? { get }
    var body: [String: String]? { get }
}

extension Endpoint {
    var scheme: String {
        return "https"
    }

    var host: Host {
        return .dev
    }
}

protocol HTTPClient {
    static func sendRequest<T: Decodable>(
        endpoint: Endpoint,
        responseModel: T.Type
    ) async -> Result<T, RequestError>
}

extension HTTPClient {
    static func sendRequest<T: Decodable>(
        endpoint: Endpoint,
        responseModel: T.Type
    ) async -> Result<T, RequestError> {
        var urlComponents = URLComponents()
        urlComponents.scheme = endpoint.scheme
        urlComponents.host = endpoint.host.rawValue
        urlComponents.path = "\(endpoint.host.envPath)\(endpoint.path)"
        guard let url = urlComponents.url else {
            return .failure(.invalidURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.allHTTPHeaderFields = endpoint.header

        if let body = endpoint.body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        }

        do {
            let (data, response) = try await URLSession.shared.data(for: request, delegate: nil)
            guard let response = response as? HTTPURLResponse else {
                return .failure(.noResponse)
            }
            switch response.statusCode {
            case 200 ... 299:
                guard let decodedResponse = try? decoder.decode(responseModel, from: data) else {
                    return .failure(.decode)
                }
                
                if let JSONString = String(data: data, encoding: String.Encoding.utf8) {
                   print(JSONString)
                }

                return .success(decodedResponse)

            case 401:
                return .failure(.unauthorized)
            default:
                return .failure(.unexpectedStatusCode)
            }
        } catch {
            return .failure(.unknown)
        }
    }
}

private let decoder: JSONDecoder = {
    let jsonDecoder = JSONDecoder()
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    jsonDecoder.dateDecodingStrategy = .formatted(formatter)
    jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
    return jsonDecoder
}()
