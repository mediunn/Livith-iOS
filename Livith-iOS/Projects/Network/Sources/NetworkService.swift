//
//  NetworkService.swift
//  network
//
//  Created by Youjin Lee on 10/12/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import Alamofire

public protocol NetworkServiceProtocol {
    func request<T: Decodable>(_ endPoint: NetworkEndpoint) async throws(NetworkError) -> T
}

public final class NetworkService: NetworkServiceProtocol {
    private let responseHandler: ResponseHandlerProtocol
    private let errorMapper: ErrorMapperProtocol
    private let interceptor: RequestInterceptor
    private let loggingMonitor

    public init(
        responseHandler: ResponseHandlerProtocol = ResponseHandler(),
        errorMapper: ErrorMapperProtocol = ErrorMapper(),
        interceptor: RequestInterceptor,
        loggingMonitor: NetworkMonitor? = nil
    ) {
        self.responseHandler = responseHandler
        self.errorMapper = errorMapper
        self.interceptor = interceptor
        self.loggingMonitor = loggingMonitor
    }
}

// MARK: - Request Method

public extension NetworkService {
    func request<T: Decodable>(_ endPoint: NetworkEndpoint) async throws(NetworkError) -> T {
        guard let endpoint = endPoint.path else {
            throw NetworkError.invalidURL
        }

        let url = Bundle.versionedBaseURL.appendingPathComponent(endpoint)
        let dataRequest: DataRequest

        switch (endPoint.body, endPoint.query) {
        case (let body?, _):
            dataRequest = AF.request(
                url,
                method: endPoint.method,
                parameters: body,
                encoder: JSONParameterEncoder.default,
                headers: endPoint.headers,
                interceptor: interceptor
            )
        case (_, let query?):
            dataRequest = AF.request(
                url,
                method: endPoint.method,
                parameters: query,
                encoding: URLEncoding.queryString,
                headers: endPoint.headers,
                interceptor: interceptor
            )
        default:
            dataRequest = AF.request(
                url,
                method: endPoint.method,
                headers: endPoint.headers,
                interceptor: interceptor
            )
        }

        if let request = dataRequest.request {
            loggingMonitor?.willSend(request, endpoint: endPoint)
        }

        do {
            let data = try await dataRequest.serializingData().value

            guard let httpResponse = dataRequest.response else {
                throw NetworkError.invalidResponse
            }

            return try await handleResponse(data: data, response: httpResponse, endpoint: endPoint)
        } catch let error as NetworkError {
            loggingMonitor?.didReceive(.failure(error), endpoint: endPoint, response: dataRequest.response)
            throw error
        } catch {
            let mappedError = errorMapper.map(error)
            loggingMonitor?.didReceive(.failure(mappedError), endpoint: endPoint, response: dataRequest.response)
            throw mappedError
        }
    }
}


// MARK: - Response Handling Extension

private extension NetworkService {
    func handleResponse<T: Decodable>(data: Data, response: HTTPURLResponse, endpoint: NetworkEndpoint) async throws(NetworkError) -> T {
        loggingMonitor?.didReceive(.success(data), endpoint: endpoint, response: response)

        return try await responseHandler.handle(data: data, response: response)
    }
}
