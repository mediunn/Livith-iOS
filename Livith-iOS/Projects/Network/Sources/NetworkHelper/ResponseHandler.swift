//
//  ResponseHandler.swift
//  network
//
//  Created by Youjin Lee on 10/12/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import Alamofire

public protocol ResponseHandlerProtocol {
    func handle<T: Decodable>(_ response: DataResponse<T, AFError>) throws -> T
}

public final class ResponseHandler: ResponseHandlerProtocol {
    private let decoder: JSONDecoder

    public init(decoder: JSONDecoder = JSONDecoder()) {
        self.decoder = decoder
    }

    public func handle<T: Decodable>(_ response: DataResponse<T, AFError>) throws -> T {
        guard let data = response.data else {
            throw NetworkError.noData
        }

        if let httpResponse = response.response {
            let statusCode = httpResponse.statusCode

            guard (200..<300).contains(statusCode) else {
                let errorMessage = try? decoder.decode(ErrorResponse.self, from: data).message
                throw NetworkError.from(statusCode: statusCode, message: errorMessage)
            }
        }

        guard let value = response.value else {
            if let error = response.error {
                throw NetworkError.decodingFailed(error)
            }
            throw NetworkError.invalidResponse
        }

        return value
    }
}
