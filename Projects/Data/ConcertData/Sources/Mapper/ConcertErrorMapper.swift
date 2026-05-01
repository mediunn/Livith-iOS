//
//  ConcertErrorMapper.swift
//  Data
//
//  Created by 김진웅 on 1/22/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import LivithNetwork
import Domain

struct ConcertErrorMapper {
    func mapToConcertError(_ error: any Error) -> ConcertError {
        if let concertError = checkForCancellation(error) {
            return concertError
        }
        
        if let networkError = error as? NetworkError {
            return mapToConcertError(networkError)
        }
        
        return .unknown
    }

    private func mapToConcertError(_ networkError: NetworkError) -> ConcertError {
        if let message = extractMessage(from: networkError),
           let concertError = mapMessageToConcertError(message) {
            return concertError
        }
        
        switch networkError {
        case .noConnection:
            return .noConnection
        case .serverError:
            return .serverError
        case .noData, .notFound:
            return .concertNotFound
        case .invalidURL, .invalidRequest:
            return .invalidRequest

        case .decodingFailed, .invalidResponse, .badRequest, .clientError:
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
             .serverError(let msg),
             .clientError(_, let msg):
            return msg
        default:
            return nil
        }
    }
    
    private func mapMessageToConcertError(_ message: String) -> ConcertError? {
        let error = ConcertError.from(message: message)
        return error == .unknown ? nil : error
    }
    
    private func checkForCancellation(_ error: any Error) -> ConcertError? {
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
