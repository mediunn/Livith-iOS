//
//  NetworkClient.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/9/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public struct NetworkClient {
    private let config: NetworkConfig
    private let requestBuilder: RequestBuilder
    private let responseHandler: ResponseHandler
    private let transport: any NetworkTransport

    public init(
        config: NetworkConfig,
        requestBuilder: RequestBuilder = RequestBuilder(),
        responseHandler: ResponseHandler = ResponseHandler()
    ) {
        self.init(
            config: config,
            requestBuilder: requestBuilder,
            responseHandler: responseHandler,
            transport: URLSessionTransport()
        )
    }

    init(
        config: NetworkConfig,
        requestBuilder: RequestBuilder = RequestBuilder(),
        responseHandler: ResponseHandler = ResponseHandler(),
        transport: any NetworkTransport
    ) {
        self.config = config
        self.requestBuilder = requestBuilder
        self.responseHandler = responseHandler
        self.transport = transport
    }

    public func request<T: Decodable>(
        _ endpoint: any NetworkEndpoint
    ) async throws(NetworkError) -> T {
        let (data, response) = try await load(endpoint)

        do {
            return try responseHandler.handle(T.self, data: data, response: response)
        } catch {
            throw .responseFailed(error)
        }
    }

    public func request(
        _ endpoint: any NetworkEndpoint
    ) async throws(NetworkError) {
        let (data, response) = try await load(endpoint)

        guard !(200..<300).contains(response.statusCode) else { return }

        do {
            _ = try responseHandler.handle(EmptyResponse.self, data: data, response: response)
        } catch {
            throw .responseFailed(error)
        }
    }
}

private extension NetworkClient {
    func load(
        _ endpoint: any NetworkEndpoint
    ) async throws(NetworkError) -> (Data, HTTPURLResponse) {
        let request: URLRequest
        do {
            request = try requestBuilder.make(endpoint: endpoint, config: config)
        } catch {
            throw .requestBuildFailed(error)
        }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await transport.data(for: request)
        } catch {
            throw .transportFailed(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw .invalidResponse
        }

        return (data, httpResponse)
    }
}
