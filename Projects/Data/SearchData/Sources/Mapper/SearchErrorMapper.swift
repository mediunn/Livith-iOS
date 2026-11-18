//
//  SearchErrorMapper.swift
//  Data
//
//  Created by 김진웅 on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain
import LivithNetworking

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
        case .timeout:
            return .noConnection
        case .cancelled:
            return .cancelled
        case .noData:
            return .noSearchResult
        case .decodingFailed, .encodingFailed, .invalidURL, .invalidRequest, .invalidResponse, .badRequest, .clientError:
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
             .serverError(_, let msg),
             .clientError(_, let msg):
            return msg
        default:
            return nil
        }
    }
    
    private func mapMessageToSearchError(_ message: String) -> SearchError? {
        switch message {
        case "genre는 JPOP | ROCK_METAL | RAP_HIPHOP | POP | INDIE | ALL 중 하나여야 해요":
            return .invalidGenre
        case "status는 ONGOING | UPCOMING | COMPLETED | CANCELED | ALL 중 하나여야 해요":
            return .invalidStatus
        case "sort는 LATEST | ALPHABETICAL 중 하나여야 해요":
            return .invalidSort
        case "size must be a positive number", "size must not be less than 1":
            return .invalidSize
        case "콘서트를 찾을 수 없어요.":
            return .invalidCursor
        case "id must not be less than 1":
            return .invalidID
        case "검색어(letter)는 필수입니다.":
            return .missingKeyword
        default:
            return nil
        }
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
