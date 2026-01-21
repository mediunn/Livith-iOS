//
//  CommentErrorMapper.swift
//  Data
//
//  Created by 김진웅 on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import LivithNetwork
import Domain

struct CommentErrorMapper {
    func mapToCommentError(_ error: any Error) -> CommentError {
        if let commentError = checkForCancellation(error) {
            return commentError
        }
        
        guard let networkError = error as? NetworkError else { return .unknown }
        
        return mapToCommentError(networkError)
    }

    private func mapToCommentError(_ networkError: NetworkError) -> CommentError {
        if let message = extractMessage(from: networkError),
           let commentError = mapMessageToCommentError(message) {
            return commentError
        }
        
        switch networkError {
        case .noConnection:
            return .noConnection
        case .serverError:
            return .serverError
        case .noData:
            return .invalidResponse
        case .notFound:
            return .unknown
        case .decodingFailed, .invalidURL, .invalidRequest, .invalidResponse, .badRequest, .clientError:
            return .invalidResponse
        case .unauthorized, .forbidden:
            return .forbidden
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
    
    private func mapMessageToCommentError(_ message: String) -> CommentError? {
        let error = CommentError.from(message: message)
        return error == .unknown ? nil : error
    }
    
    private func checkForCancellation(_ error: any Error) -> CommentError? {
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
