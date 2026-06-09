//
//  DebugNetworkPlugin.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/13/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public struct DebugNetworkPlugin: NetworkPlugin {
    private let output: @Sendable (String) -> Void

    public init(
        output: @escaping @Sendable (String) -> Void = { print($0) }
    ) {
        self.output = output
    }

    public func willSend(
        _ request: URLRequest,
        endpoint: NetworkEndpoint
    ) async {
        output("[요청] \(request.httpMethod ?? "-") \(sanitizedURLString(from: request.url))")
    }

    public func didReceive(
        _ result: Result<NetworkPluginResponse, NetworkError>,
        request: URLRequest,
        endpoint: NetworkEndpoint
    ) async {
        switch result {
        case .success(let response):
            let status = response.response.statusCode
            let emoji = (200..<300).contains(status) ? "✅" : "⚠️"
            output("[\(emoji) \(status)] \(request.httpMethod ?? "-") \(sanitizedURLString(from: request.url))")
        case .failure(let error):
            output("[❌ \(errorSummary(error))] \(request.httpMethod ?? "-") \(sanitizedURLString(from: request.url))")
        }
    }
}

private extension DebugNetworkPlugin {
    func sanitizedURLString(from url: URL?) -> String {
        guard let url else {
            return "-"
        }
        return url.path
    }

    func errorSummary(_ error: NetworkError) -> String {
        switch error {
        case .invalidURL:
            return "invalidURL"
        case .invalidRequest:
            return "invalidRequest"
        case .encodingFailed:
            return "encodingFailed"
        case .noConnection:
            return "noConnection"
        case .timeout:
            return "timeout"
        case .cancelled:
            return "cancelled"
        case .invalidResponse:
            return "invalidResponse"
        case .noData:
            return "noData"
        case .decodingFailed:
            return "decodingFailed"
        case .badRequest:
            return "badRequest"
        case .unauthorized:
            return "unauthorized"
        case .forbidden:
            return "forbidden"
        case .notFound:
            return "notFound"
        case .clientError(let statusCode, _):
            return "clientError(\(statusCode))"
        case .serverError(let statusCode, _):
            return "serverError(\(statusCode))"
        case .unknown:
            return "unknown"
        }
    }
}
