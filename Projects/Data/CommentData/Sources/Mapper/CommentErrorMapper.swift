//
//  CommentErrorMapper.swift
//  Data
//
//  Created by 김진웅 on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import LivithNetworking
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
        case .timeout:
            return .noConnection
        case .cancelled:
            return .cancelled
        case .noData:
            return .invalidResponse
        case .notFound:
            return .unknown
        case .decodingFailed, .encodingFailed, .invalidURL, .invalidRequest, .invalidResponse, .badRequest, .clientError:
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
             .serverError(_, let msg),
             .clientError(_, let msg):
            return msg
        default:
            return nil
        }
    }
    
    private func mapMessageToCommentError(_ message: String) -> CommentError? {
        switch message {
        case "해당 콘서트가 존재하지 않습니다.":
            return .concertNotFound
        case "id는 양의 정수여야 합니다.":
            return .invalidID
        case "size must not be less than 1":
            return .invalidSize
        case "유효하지 않은 cursor 형식입니다.":
            return .invalidCursor
        case "content should not be empty":
            return .emptyContent
        case "content must be shorter than or equal to 400 characters":
            return .contentTooLong
        case "해당 유저가 존재하지 않습니다.":
            return .userNotFound
        case "탈퇴한 회원입니다.":
            return .withdrawn
        case "댓글을 찾을 수 없습니다.":
            return .commentNotFound
        case "본인의 댓글만 삭제할 수 있습니다.":
            return .forbidden
        case "content must be shorter than or equal to 200 characters":
            return .reportReasonTooLong
        default:
            return nil
        }
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
