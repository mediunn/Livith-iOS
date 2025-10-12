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
            case .invalidURL:
                return .invalidURL
            case .responseValidationFailed:
                return .invalidResponse
            default:
                return .unknown(afError)
            }
        }

        return .unknown(error)
    }
}
