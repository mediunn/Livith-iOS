//
//  SearchErrorMapper.swift
//  Data
//
//  Created by 김진웅 on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain
import LivithNetwork

struct SearchErrorMapper {
    func mapToSearchError(_ error: any Error) -> SearchError {
        if let searchError = checkForCancellation(error) {
            return searchError
        }
        
        guard let networkError = error as? NetworkError else { return .unknown }
        
        return mapToSearchError(networkError)
    }

    private func mapToSearchError(_ networkError: NetworkError) -> SearchError {
        if let message = extractMessage(from: networkError),
           let searchError = mapMessageToSearchError(message) {
            return searchError
        }
        
        switch networkError {
        case .noConnection:
            return .noConnection
        case .serverError:
            return .serverError
        case .noData:
            return .noSearchResult
        case .decodingFailed, .invalidURL, .invalidRequest, .invalidResponse, .badRequest, .clientError:
            return .invalidResponse
        case .unauthorized, .forbidden, .notFound:
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
             .serverError(let msg),
             .clientError(_, let msg):
            return msg
        default:
            return nil
        }
    }
    
    private func mapMessageToSearchError(_ message: String) -> SearchError? {
        let error = SearchError.from(message: message)
        return error == .unknown ? nil : error
    }
    
    private func checkForCancellation(_ error: any Error) -> SearchError? {
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
