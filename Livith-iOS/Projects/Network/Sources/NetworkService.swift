//
//  NetworkService.swift
//  network
//
//  Created by Youjin Lee on 10/12/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Combine
import Foundation

import Alamofire

public protocol NetworkServiceProtocol {
    func request<T: Decodable>(_ endPoint: NetworkEndpoint) -> AnyPublisher<T, NetworkError>
}

public final class NetworkService: NetworkServiceProtocol {
    private let responseHandler: ResponseHandlerProtocol
    private let errorMapper: ErrorMapperProtocol

    public init(
        responseHandler: ResponseHandlerProtocol = ResponseHandler(),
        errorMapper: ErrorMapperProtocol = ErrorMapper()
    ) {
        self.responseHandler = responseHandler
        self.errorMapper = errorMapper
    }
}

// MARK: - Request Method

public extension NetworkService {
    func request<T: Decodable>(_ endPoint: NetworkEndpoint) -> AnyPublisher<T, NetworkError> {
        guard let endpoint = endPoint.endPoint else {
            return Fail(error: NetworkError.invalidURL)
                .eraseToAnyPublisher()
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
                headers: endPoint.headers
            )
        case (_, let query?):
            dataRequest = AF.request(
                url,
                method: endPoint.method,
                parameters: query,
                encoding: URLEncoding.queryString,
                headers: endPoint.headers
            )
        default:
            dataRequest = AF.request(
                url,
                method: endPoint.method,
                headers: endPoint.headers
            )
        }

        return handleResponse(dataRequest)
    }
}


// MARK: - Response Handling Extension

private extension NetworkService {
    func handleResponse<T: Decodable>(_ dataRequest: DataRequest) -> AnyPublisher<T, NetworkError> {
        return dataRequest
            .publishDecodable(type: T.self)
            .tryMap { [responseHandler] response in
                try responseHandler.handle(response)
            }
            .mapError { [errorMapper] error in
                errorMapper.map(error)
            }
            .eraseToAnyPublisher()
    }
}
