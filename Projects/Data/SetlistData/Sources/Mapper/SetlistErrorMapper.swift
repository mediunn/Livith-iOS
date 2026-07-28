//
//  SetlistErrorMapper.swift
//  Data
//
//  Created by 김진웅 on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import LivithNetworking
import Domain

struct SetlistErrorMapper {
    func mapToSetlistError(_ error: any Error) -> SetlistError {
        if let setlistError = checkForCancellation(error) {
            return setlistError
        }
        
        if let networkError = error as? NetworkError {
            return mapToSetlistError(networkError)
        }
        
        return .unknown
    }

    private func mapToSetlistError(_ networkError: NetworkError) -> SetlistError {
        if let message = extractMessage(from: networkError),
           let setlistError = mapMessageToSetlistError(message) {
            return setlistError
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
        case .noData, .notFound:
            return .notFound
        case .decodingFailed, .encodingFailed, .invalidURL, .invalidRequest, .invalidResponse, .badRequest, .clientError:
            return .invalidResponse
        case .unauthorized, .forbidden, .unknown:
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
    
    private func mapMessageToSetlistError(_ message: String) -> SetlistError? {
        let error = SetlistError.from(message: message)
        return error == .unknown ? nil : error
    }
    
    private func checkForCancellation(_ error: any Error) -> SetlistError? {
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
