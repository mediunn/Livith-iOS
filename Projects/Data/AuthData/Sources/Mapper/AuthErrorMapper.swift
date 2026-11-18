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
        switch message {
        case "탈퇴한 회원입니다.":
            return .withdrawn
        case "탈퇴 후 7일이 지나지 않았어요":
            return .recentlyWithdrawn
        case "이미 존재하는 닉네임이에요.":
            return .duplicateNickname
        case "nickname must be shorter than or equal to 10 characters":
            return .nicknameTooLong
        case "nickname should not be empty":
            return .emptyNickname
        case "해당 유저가 존재하지 않습니다.":
            return .userNotFound
        case "이미 탈퇴한 회원입니다.", "이미 탈퇴한 회원이에요.":
            return .withdrawn
        case "reason should not be empty":
            return .emptyReason
        case "최소 1개의 장르는 선택해야 합니다.":
            return .emptyGenreList
        case "해당 장르를 찾을 수 없습니다.":
            return .genreNotFound
        case "최대 3개의 장르만 선택할 수 있습니다.":
            return .genreExceedsLimit
        case "해당 아티스를 찾을 수 없습니다.":
            return .artistNotFound
        case "최대 3개의 아티스트만 선택할 수 있습니다.":
            return .artistExceedsLimit
        default:
            return nil
        }
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
