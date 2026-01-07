//
//  LoginErrorMapper.swift
//  LoginData
//
//  Created by 김진웅 on 12/5/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import SocialAuth
import LivithNetwork
import LoginDomain

struct LoginErrorMapper {
    func mapToDomainError(from error: Error) -> LoginError {
        if let loginError = error as? LoginError {
            return loginError
        }
        if let authError = error as? SocialAuthError {
            return mapToDomainError(authError)
        }
        if let networkError = error as? NetworkError {
            return mapToDomainError(networkError)
        }

        return .unknown
    }

    private func mapToDomainError(_ error: SocialAuthError) -> LoginError {
        switch error {
        case .canceled:
            return .canceled
        case .networkError:
            return .noConnection
        case .missingToken, .unknown:
            return .unknown
        }
    }
    
    private func mapToDomainError(_ error: NetworkError) -> LoginError {
        switch error {
        case .noConnection:
            return .noConnection
        case .forbidden:
            return .forbidden
        case .notFound:
            return .notFound
        case .serverError:
            return .serverError
        case .noData:
            return .noData
        default:
            return .unknown
        }
    }
}
