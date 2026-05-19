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
        output(formattedLog("➡️ \(request.httpMethod ?? "-") \(sanitizedURLString(from: request.url))"))
    }

    public func didReceive(
        _ result: Result<NetworkPluginResponse, NetworkError>,
        request: URLRequest,
        endpoint: NetworkEndpoint
    ) async {
        switch result {
        case .success(let response):
            output(formattedLog("⬅️ \(response.response.statusCode) \(sanitizedURLString(from: request.url))"))
        case .failure(let error):
            output(formattedLog("❌ \(errorSummary(error)) \(sanitizedURLString(from: request.url))"))
        }
    }
}

private extension DebugNetworkPlugin {
    func formattedLog(_ message: String) -> String {
        """
        ──── LivithNetworking ────
        \(message)
        ──────────────────────────
        """
    }

    func sanitizedURLString(from url: URL?) -> String {
        guard let url,
              let sourceComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        else {
            return "-"
        }

        var components = URLComponents()
        components.scheme = sourceComponents.scheme
        components.host = sourceComponents.host
        components.port = sourceComponents.port
        components.path = sourceComponents.path

        return components.string ?? "-"
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
