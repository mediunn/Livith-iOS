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
    private let plugins: [any NetworkPlugin]
    private let etagCache: ETagCacheHandler

    public init(
        config: NetworkConfig,
        requestBuilder: RequestBuilder = RequestBuilder(),
        responseHandler: ResponseHandler = ResponseHandler(),
        interceptor: (any RequestInterceptor)? = nil,
        plugins: [any NetworkPlugin] = []
    ) {
        self.init(
            config: config,
            requestBuilder: requestBuilder,
            responseHandler: responseHandler,
            transport: URLSessionTransport(),
            interceptor: interceptor,
            plugins: plugins
        )
    }

    init(
        config: NetworkConfig,
        requestBuilder: RequestBuilder = RequestBuilder(),
        responseHandler: ResponseHandler = ResponseHandler(),
        transport: any NetworkTransport,
        interceptor: (any RequestInterceptor)? = nil,
        plugins: [any NetworkPlugin] = [],
        etagStore: any ETagCacheStore = MemoryETagCacheStore()
    ) {
        self.config = config
        self.requestBuilder = requestBuilder
        self.responseHandler = responseHandler
        self.transport = transport
        self.interceptor = interceptor
        self.plugins = plugins
        self.etagCache = ETagCacheHandler(store: etagStore)
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

    public func removeAllETagCache() async {
        await etagCache.removeAll()
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
            attempt: RequestAttempt()
        )
    }

    func load(
        _ request: URLRequest,
        for endpoint: NetworkEndpoint,
        attempt: RequestAttempt
    ) async throws(NetworkError) -> (Data, HTTPURLResponse) {
        let preparedRequest = try await prepare(request, for: endpoint)
        let adaptedRequest = try await adapt(preparedRequest, for: endpoint)
        let key = etagCache.key(for: adaptedRequest, endpoint: endpoint)
        var sendRequest = adaptedRequest
        await etagCache.apply(to: &sendRequest, key: key, skipsETag: attempt.skipsETag)

        await notifyWillSend(sendRequest, for: endpoint)

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await transport.data(for: sendRequest)
        } catch {
            let networkError = mapTransportError(error)
            await notifyDidReceive(.failure(networkError), request: sendRequest, for: endpoint)
            throw networkError
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            await notifyDidReceive(.failure(.invalidResponse), request: sendRequest, for: endpoint)
            throw .invalidResponse
        }

        await notifyDidReceive(
            .success(NetworkPluginResponse(data: data, response: httpResponse)),
            request: sendRequest,
            for: endpoint
        )

        if try await shouldRetry(sendRequest, for: endpoint, response: httpResponse, attempt: attempt) {
            return try await load(request, for: endpoint, attempt: attempt.retrying())
        }

        return try await handleETag(
            data: data,
            response: httpResponse,
            request: request,
            sentRequest: sendRequest,
            key: key,
            endpoint: endpoint,
            attempt: attempt
        )
    }

    func prepare(
        _ request: URLRequest,
        for endpoint: NetworkEndpoint
    ) async throws(NetworkError) -> URLRequest {
        var preparedRequest = request

        for plugin in plugins {
            preparedRequest = try await plugin.prepare(preparedRequest, endpoint: endpoint)
        }

        return preparedRequest
    }

    func notifyWillSend(
        _ request: URLRequest,
        for endpoint: NetworkEndpoint
    ) async {
        for plugin in plugins {
            await plugin.willSend(request, endpoint: endpoint)
        }
    }

    func notifyDidReceive(
        _ result: Result<NetworkPluginResponse, NetworkError>,
        request: URLRequest,
        for endpoint: NetworkEndpoint
    ) async {
        for plugin in plugins {
            await plugin.didReceive(result, request: request, endpoint: endpoint)
        }
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
        attempt: RequestAttempt
    ) async throws(NetworkError) -> Bool {
        guard endpoint.requiresAuthentication,
              attempt.canRetry,
              response.statusCode == 401,
              let interceptor
        else {
            return false
        }

        let result = try await interceptor.retry(
            request,
            dueTo: .unauthorized(message: nil),
            response: response,
            retryCount: attempt.retryCount
        )

        switch result {
        case .retry:
            return true
        case .doNotRetry:
            return false
        }
    }

    func handleETag(
        data: Data,
        response: HTTPURLResponse,
        request: URLRequest,
        sentRequest: URLRequest,
        key: String?,
        endpoint: NetworkEndpoint,
        attempt: RequestAttempt
    ) async throws(NetworkError) -> (Data, HTTPURLResponse) {
        let result = await etagCache.handle(
            data: data,
            response: response,
            request: sentRequest,
            key: key
        )

        switch result {
        case .response(let data, let response):
            return (data, response)
        case .fallback:
            guard attempt.canFallback else {
                return (data, response)
            }

            return try await load(request, for: endpoint, attempt: attempt.fallingBack())
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
