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
    private let interceptor: (any RequestInterceptor)?

    public init(
        config: NetworkConfig,
        requestBuilder: RequestBuilder = RequestBuilder(),
        responseHandler: ResponseHandler = ResponseHandler(),
        interceptor: (any RequestInterceptor)? = nil
    ) {
        self.init(
            config: config,
            requestBuilder: requestBuilder,
            responseHandler: responseHandler,
            transport: URLSessionTransport(),
            interceptor: interceptor
        )
    }

    init(
        config: NetworkConfig,
        requestBuilder: RequestBuilder = RequestBuilder(),
        responseHandler: ResponseHandler = ResponseHandler(),
        transport: any NetworkTransport,
        interceptor: (any RequestInterceptor)? = nil
    ) {
        self.config = config
        self.requestBuilder = requestBuilder
        self.responseHandler = responseHandler
        self.transport = transport
        self.interceptor = interceptor
    }

    public func request<T: Decodable>(
        _ endpoint: NetworkEndpoint
    ) async throws(NetworkError) -> T {
        let (data, response) = try await load(endpoint)

        do {
            return try responseHandler.handle(T.self, data: data, response: response)
        } catch {
            throw map(error)
        }
    }

    public func request(
        _ endpoint: NetworkEndpoint
    ) async throws(NetworkError) {
        let (data, response) = try await load(endpoint)

        guard !(200..<300).contains(response.statusCode) else { return }

        do {
            _ = try responseHandler.handle(EmptyResponse.self, data: data, response: response)
        } catch {
            throw map(error)
        }
    }
}

private extension NetworkClient {
    func load(
        _ endpoint: NetworkEndpoint
    ) async throws(NetworkError) -> (Data, HTTPURLResponse) {
        let request: URLRequest
        do {
            request = try requestBuilder.make(endpoint: endpoint, config: config)
        } catch {
            throw map(error)
        }

        return try await load(
            request,
            for: endpoint,
            retryCount: 0
        )
    }

    func load(
        _ request: URLRequest,
        for endpoint: NetworkEndpoint,
        retryCount: Int
    ) async throws(NetworkError) -> (Data, HTTPURLResponse) {
        let adaptedRequest = try await adapt(request, for: endpoint)

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await transport.data(for: adaptedRequest)
        } catch {
            throw mapTransportError(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw .invalidResponse
        }

        if try await shouldRetry(
            adaptedRequest,
            for: endpoint,
            response: httpResponse,
            retryCount: retryCount
        ) {
            return try await load(
                request,
                for: endpoint,
                retryCount: retryCount + 1
            )
        }

        return (data, httpResponse)
    }

    func adapt(
        _ request: URLRequest,
        for endpoint: NetworkEndpoint
    ) async throws(NetworkError) -> URLRequest {
        guard endpoint.requiresAuthentication,
              let interceptor
        else {
            return request
        }

        return try await interceptor.adapt(request)
    }

    func shouldRetry(
        _ request: URLRequest,
        for endpoint: NetworkEndpoint,
        response: HTTPURLResponse,
        retryCount: Int
    ) async throws(NetworkError) -> Bool {
        guard endpoint.requiresAuthentication,
              retryCount == 0,
              response.statusCode == 401,
              let interceptor
        else {
            return false
        }

        let result = try await interceptor.retry(
            request,
            dueTo: .unauthorized(message: nil),
            response: response,
            retryCount: retryCount
        )

        switch result {
        case .retry:
            return true
        case .doNotRetry:
            return false
        }
    }

    func map(_ error: RequestBuildError) -> NetworkError {
        switch error {
        case .invalidURL:
            return .invalidURL
        case .encodingFailed(let error):
            return .encodingFailed(error)
        }
    }

    func map(_ error: ResponseError) -> NetworkError {
        switch error {
        case .invalidStatusCode(let statusCode, let message):
            return .from(statusCode: statusCode, message: message)
        case .noData:
            return .noData
        case .decodingFailed(let error):
            return .decodingFailed(error)
        }
    }

    func mapTransportError(_ error: Error) -> NetworkError {
        if error is CancellationError {
            return .cancelled
        }

        guard let urlError = error as? URLError else {
            return .unknown(error)
        }

        switch urlError.code {
        case .cancelled:
            return .cancelled
        case .timedOut:
            return .timeout(urlError)
        case .notConnectedToInternet,
             .networkConnectionLost,
             .cannotConnectToHost,
             .cannotFindHost,
             .dnsLookupFailed:
            return .noConnection(urlError)
        default:
            return .unknown(urlError)
        }
    }
}
