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
    private let session: Session
    private let responseHandler: ResponseHandlerProtocol
    private let errorMapper: ErrorMapperProtocol

    public init(
        session: Session,
        responseHandler: ResponseHandlerProtocol = ResponseHandler(),
        errorMapper: ErrorMapperProtocol = ErrorMapper()
    ) {
        self.session = session
        self.responseHandler = responseHandler
        self.errorMapper = errorMapper
    }

    public convenience init(
        interceptor: RequestInterceptor? = nil,
        eventMonitors: [EventMonitor] = [LoggingMonitor.init()],
        configuration: URLSessionConfiguration = .default
    ) {
        let session = Session(
            configuration: configuration,
            interceptor: interceptor,
            eventMonitors: eventMonitors
        )
        self.init(session: session)
    }
}

// MARK: - Request Method

public extension NetworkService {
    func request<T: Decodable>(_ endPoint: NetworkEndpoint) async throws(NetworkError) -> T {
        guard let endpoint = endPoint.path else {
            throw NetworkError.invalidURL
        }

        let url = Bundle.baseURL.appendingPathComponent(endpoint)
        let dataRequest: DataRequest

        switch (endPoint.body, endPoint.query) {
        case (let body?, _):
            dataRequest = session.request(
                url,
                method: endPoint.method,
                parameters: body,
                encoder: JSONParameterEncoder.default,
                headers: endPoint.headers
            )
        case (_, let query?):
            let encoding = URLEncoding(arrayEncoding: .noBrackets)
            dataRequest = session.request(
                url,
                method: endPoint.method,
                parameters: query,
                encoding: encoding,
                headers: endPoint.headers
            )
        default:
            dataRequest = session.request(
                url,
                method: endPoint.method,
                headers: endPoint.headers
            )
        }

        do {
            let data = try await dataRequest.serializingData().value

            guard let httpResponse = dataRequest.response else {
                throw NetworkError.invalidResponse
            }

            return try await handleResponse(data: data, response: httpResponse)
        } catch let error as NetworkError {
            throw error
        } catch {
            throw errorMapper.map(error)
        }
    }
}


// MARK: - Response Handling Extension

private extension NetworkService {
    func handleResponse<T: Decodable>(data: Data, response: HTTPURLResponse) async throws(NetworkError) -> T {
        return try await responseHandler.handle(data: data, response: response)
    }
}
