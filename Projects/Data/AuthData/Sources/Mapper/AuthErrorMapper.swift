//
//  AuthErrorMapper.swift
//  Data
//
//  Created by 김진웅 on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain
import LivithNetworking

struct AuthErrorMapper {
    func mapToAuthError(_ error: any Error) -> AuthError {
        if let authError = checkForCancellation(error) {
            return authError
        }
        
        guard let networkError = error as? NetworkError else { return .unknown }
        
        return mapToAuthError(networkError)
    }

    private func mapToAuthError(_ networkError: NetworkError) -> AuthError {
        if let message = extractMessage(from: networkError),
           let authError = mapMessageToAuthError(message) {
            return authError
        }
        
        switch networkError {
        case .noConnection:
            return .noConnection
        case .serverError:
            return .serverError
        case .timeout:
            return .noConnection
        case .cancelled:
            return .cancelled
        case .noData, .decodingFailed, .encodingFailed, .invalidURL, .invalidRequest, .invalidResponse, .badRequest, .clientError:
            return .invalidResponse
        case .unauthorized, .forbidden, .notFound:
             // AuthError handles some specifics like .withdrawn, .recentlyWithdrawn via message mapping.
             // If message mapping failed, generic fallback.
            return .unknown
        case .unknown:
            return .unknown
        }
    }
    
    private func extractMessage(from networkError: NetworkError) -> String? {
        switch networkError {
        case .badRequest(let msg),
             .unauthorized(let msg),
             .forbidden(let msg),
             .notFound(let msg),
             .serverError(_, let msg),
             .clientError(_, let msg):
            return msg
        default:
            return nil
        }
    }
    
    private func mapMessageToAuthError(_ message: String) -> AuthError? {
        let error = AuthError.from(message: message)
        return error == .unknown ? nil : error
    }
    
    private func checkForCancellation(_ error: any Error) -> AuthError? {
        if error is CancellationError {
            return .cancelled
        }
        
        if let urlError = error as? URLError, urlError.code == .cancelled {
            return .cancelled
        }
        
        if let networkError = error as? NetworkError {
            switch networkError {
            case .noConnection(let wrappedError), .unknown(let wrappedError):
                return checkForCancellation(wrappedError)
            default:
                return nil
            }
        }
        
        return nil
    }
}
