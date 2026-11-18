//
//  ConcertErrorMapper.swift
//  Data
//
//  Created by 김진웅 on 1/22/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import LivithNetworking
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
        case .timeout:
            return .noConnection
        case .cancelled:
            return .cancelled
        case .noData, .notFound:
            return .concertNotFound
        case .invalidURL, .invalidRequest:
            return .invalidRequest

        case .decodingFailed, .encodingFailed, .invalidResponse, .badRequest, .clientError:
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
    
    private func mapMessageToConcertError(_ message: String) -> ConcertError? {
        switch message {
        case "id는 양의 정수여야 합니다.", "id must not be less than 1":
            return .invalidID
        case "size must not be less than 1":
            return .invalidSize
        case "해당 콘서트를 찾을 수 없습니다.", "해당 콘서트가 존재하지 않습니다.":
            return .concertNotFound
        case "해당 아티스트를 찾을 수 없습니다.":
            return .artistNotFound
        default:
            return nil
        }
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
