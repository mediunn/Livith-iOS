//
//  ErrorMapper.swift
//  network
//
//  Created by Youjin Lee on 10/12/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import Alamofire

public protocol ErrorMapperProtocol {
    func map(_ error: Error) -> NetworkError
}

public final class ErrorMapper: ErrorMapperProtocol {
    public init() {}

    public func map(_ error: Error) -> NetworkError {
        if let networkError = error as? NetworkError {
            return networkError
        }

        if let afError = error as? AFError {
            switch afError {
            case .sessionTaskFailed(error: let error):
                return .noConnection(error)
            case .invalidURL:
                return .invalidURL
            case .responseValidationFailed(let reason):
                return mapResponseValidationError(reason)
            default:
                return .unknown(afError)
            }
        }

        return .unknown(error)
    }

    private func mapResponseValidationError(_ reason: AFError.ResponseValidationFailureReason) -> NetworkError {
        switch reason {
        case .unacceptableStatusCode(let code):
            return NetworkError.from(statusCode: code)
        default:
            return .invalidResponse
        }
    }
}
