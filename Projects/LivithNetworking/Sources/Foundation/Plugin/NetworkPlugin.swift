//
//  NetworkPlugin.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/13/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

// MARK: - NetworkPlugin

public protocol NetworkPlugin: Sendable {
    func prepare(
        _ request: URLRequest,
        endpoint: NetworkEndpoint
    ) async throws(NetworkError) -> URLRequest

    func willSend(
        _ request: URLRequest,
        endpoint: NetworkEndpoint
    ) async

    func didReceive(
        _ result: Result<NetworkPluginResponse, NetworkError>,
        request: URLRequest,
        endpoint: NetworkEndpoint
    ) async
}

public extension NetworkPlugin {
    func prepare(
        _ request: URLRequest,
        endpoint: NetworkEndpoint
    ) async throws(NetworkError) -> URLRequest {
        request
    }

    func willSend(
        _ request: URLRequest,
        endpoint: NetworkEndpoint
    ) async {}

    func didReceive(
        _ result: Result<NetworkPluginResponse, NetworkError>,
        request: URLRequest,
        endpoint: NetworkEndpoint
    ) async {}
}

// MARK: - NetworkPluginResponse

public struct NetworkPluginResponse: Sendable {
    public let data: Data
    public let response: HTTPURLResponse

    public init(
        data: Data,
        response: HTTPURLResponse
    ) {
        self.data = data
        self.response = response
    }
}
