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

        case .timeout:
            return .noConnection

        case .cancelled:
            return .cancelled

        case .invalidURL, .invalidRequest:
            return .invalidRequest

        case .noData, .decodingFailed, .encodingFailed, .invalidResponse:
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
        switch message {
        case "해당 유저가 존재하지 않습니다.":
            return .userNotFound
        case "이미 존재하는 닉네임이에요.":
            return .duplicateNickname
        case "nickname must be shorter than or equal to 10 characters":
            return .nicknameTooLong
        case "탈퇴한 회원입니다.":
            return .withdrawn
        case "nickname should not be empty":
            return .emptyNickname
        case "해당 콘서트가 존재하지 않습니다.":
            return .concertNotFound
        case "concertId must be an integer number":
            return .invalidConcertID
        default:
            return .unknown
        }
    }
}
