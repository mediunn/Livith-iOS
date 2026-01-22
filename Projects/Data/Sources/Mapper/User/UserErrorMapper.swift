//
//  UserErrorMapper.swift
//  Data
//
//  Created by 김진웅 on 2026/01/22.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain
import LivithNetwork

struct UserErrorMapper {
    func mapToUserError(_ error: Error) -> UserError {
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
    
    private func mapNetworkError(_ error: NetworkError) -> UserError {
        switch error {
        case .noConnection(let underlyingError):
            if let urlError = underlyingError as? URLError, urlError.code == .cancelled {
                return .cancelled
            }
            return .noConnection
            
        case .serverError:
            return .serverError
            
        case .noData, .decodingFailed, .invalidURL, .invalidRequest, .invalidResponse:
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
    
    private func mapFromMessage(_ message: String?) -> UserError {
        guard let message else { return .unknown }
        return UserError.from(message: message)
    }
}
