//
//  NetworkService.swift
//  network
//
//  Created by Youjin Lee on 10/12/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import Alamofire

public final class NetworkService<EndPoint: NetworkEndpoint> {
    private let session: Session
    private let responseHandler: ResponseHandlerProtocol
    private let errorMapper: ErrorMapperProtocol
    private let authInterceptor: RequestInterceptor?

    public init(
        session: Session,
        authInterceptor: RequestInterceptor? = AuthenticationInterceptor(),
        responseHandler: ResponseHandlerProtocol = ResponseHandler(),
        errorMapper: ErrorMapperProtocol = ErrorMapper()
    ) {
        self.session = session
        self.responseHandler = responseHandler
        self.errorMapper = errorMapper
        self.authInterceptor = authInterceptor
    }

    public convenience init(
        interceptor: RequestInterceptor? = AuthenticationInterceptor(),
        eventMonitors: [EventMonitor] = [LoggingMonitor.init()],
        configuration: URLSessionConfiguration = .default
    ) {
        let session = Session(
            configuration: configuration,
            interceptor: nil,
            eventMonitors: eventMonitors
        )
        self.init(session: session, authInterceptor: interceptor)
    }
}

// MARK: - Request Method

public extension NetworkService {
    func request<T: Decodable>(_ endPoint: EndPoint) async throws(NetworkError) -> T {
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
                headers: endPoint.headers,
                interceptor: interceptor(for: endPoint)
            )
        case (_, let query?):
            let encoding = URLEncoding(arrayEncoding: .noBrackets)
            dataRequest = session.request(
                url,
                method: endPoint.method,
                parameters: query,
                encoding: encoding,
                headers: endPoint.headers,
                interceptor: interceptor(for: endPoint)
            )
        default:
            dataRequest = session.request(
                url,
                method: endPoint.method,
                headers: endPoint.headers,
                interceptor: interceptor(for: endPoint)
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
    func interceptor(for endPoint: EndPoint) -> RequestInterceptor? {
        endPoint.requiresInterceptor ? authInterceptor : nil
    }

    func handleResponse<T: Decodable>(data: Data, response: HTTPURLResponse) async throws(NetworkError) -> T {
        return try await responseHandler.handle(data: data, response: response)
    }
}
