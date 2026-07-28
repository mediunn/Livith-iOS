//
//  PreferenceErrorMapper.swift
//  PreferenceData
//
//  Created by 김진웅 on 2/4/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain
import LivithNetworking

struct PreferenceErrorMapper {
    func mapToPreferenceError(_ error: Error) -> PreferenceError {
        if error is CancellationError {
            return .cancelled
        }
        
        if let urlError = error as? URLError, urlError.code == .cancelled {
            return .cancelled
        }
        
        guard let networkError = error as? NetworkError else {
            return .unknown
        }
        
        return mapNetworkError(networkError)
    }
    
    private func mapNetworkError(_ error: NetworkError) -> PreferenceError {
        switch error {
        case .noConnection(let underlyingError):
            if let urlError = underlyingError as? URLError, urlError.code == .cancelled {
                return .cancelled
            }
            return .noConnection

        case .serverError:
            return .serverError

        case .timeout:
            return .noConnection

        case .cancelled:
            return .cancelled

        case .noData, .decodingFailed, .encodingFailed, .invalidURL, .invalidRequest, .invalidResponse:
            return .invalidResponse

        case .badRequest(let message):
            return mapFromMessage(message)

        case .unauthorized:
            return .unknown

        case .forbidden(let message):
            return mapFromMessage(message)

        case .notFound(let message):
            return mapFromMessage(message)

        case .clientError:
            return .invalidResponse

        case .unknown(let underlyingError):
            if let urlError = underlyingError as? URLError, urlError.code == .cancelled {
                return .cancelled
            }
            return .unknown
        }
    }
    
    private func mapFromMessage(_ message: String?) -> PreferenceError {
        guard let message else { return .unknown }
        return PreferenceError.from(message: message)
    }
}
