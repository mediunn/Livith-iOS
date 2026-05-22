//
//  RequestBuilder.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/8/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

enum RequestBuildError: Error {
    case invalidURL
    case encodingFailed(Error)
}

struct RequestBuilder: Sendable {
    private let encoder: JSONEncoder

    init(encoder: JSONEncoder = JSONEncoder()) {
        self.encoder = encoder
    }

    func make(
        endpoint: NetworkEndpoint,
        config: NetworkConfig
    ) throws(RequestBuildError) -> URLRequest {
        let url = try makeURL(endpoint: endpoint, config: config)
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue

        try applyBody(from: endpoint.task, to: &request)
        applyHeaders(endpoint.headers, to: &request)

        return request
    }
}

private extension RequestBuilder {
    func makeURL(
        endpoint: NetworkEndpoint,
        config: NetworkConfig
    ) throws(RequestBuildError) -> URL {
        guard var components = URLComponents(url: config.baseURL, resolvingAgainstBaseURL: false),
              isValidHTTPURL(components) 
        else {
            throw .invalidURL
        }

        components.path = normalizedPath(basePath: components.path, endpointPath: endpoint.path)
        let queryItemList = queryItems(from: endpoint.task)
        if !queryItemList.isEmpty {
            components.queryItems = (components.queryItems ?? []) + queryItemList
        }

        guard let url = components.url else {
            throw .invalidURL
        }

        return url
    }

    func isValidHTTPURL(_ components: URLComponents) -> Bool {
        guard let scheme = components.scheme?.lowercased(),
              scheme == "http" || scheme == "https",
              let host = components.host,
              !host.isEmpty 
        else {
            return false
        }

        return true
    }

    func normalizedPath(basePath: String, endpointPath: String) -> String {
        let normalizedBasePath = basePath.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let normalizedEndpointPath = endpointPath.trimmingCharacters(in: CharacterSet(charactersIn: "/"))

        guard !normalizedBasePath.isEmpty else {
            return "/" + normalizedEndpointPath
        }

        guard !normalizedEndpointPath.isEmpty else {
            return "/" + normalizedBasePath
        }

        return "/" + normalizedBasePath + "/" + normalizedEndpointPath
    }

    func queryItems(from task: RequestTask) -> [URLQueryItem] {
        switch task {
        case .plain, .body:
            return []
        case .query(let queryItemList):
            return queryItemList
        case .queryAndBody(let queryItemList, _):
            return queryItemList
        }
    }

    func applyBody(
        from task: RequestTask,
        to request: inout URLRequest
    ) throws(RequestBuildError) {
        guard let body = body(from: task) else { return }

        do {
            request.httpBody = try encoder.encode(EncodableBody(body))
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        } catch {
            throw .encodingFailed(error)
        }
    }

    func body(from task: RequestTask) -> (any Encodable)? {
        switch task {
        case .plain, .query:
            return nil
        case .body(let body):
            return body
        case .queryAndBody(_, let body):
            return body
        }
    }

    func applyHeaders(
        _ headers: [String: String],
        to request: inout URLRequest
    ) {
        headers.forEach { field, value in
            request.setValue(value, forHTTPHeaderField: field)
        }
    }
}

private struct EncodableBody: Encodable {
    private let body: any Encodable

    init(_ body: any Encodable) {
        self.body = body
    }

    func encode(to encoder: any Encoder) throws {
        try body.encode(to: encoder)
    }
}
