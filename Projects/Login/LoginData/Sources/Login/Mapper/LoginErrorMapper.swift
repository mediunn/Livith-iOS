//
//  LoginErrorMapper.swift
//  LoginData
//
//  Created by 김진웅 on 12/5/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import Auth
import LivithNetwork
import LoginDomain

struct LoginErrorMapper {
    func mapToDomainError(from error: Error) -> LoginError {
        if let loginError = error as? LoginError {
            return loginError
        }
        if let authError = error as? AuthError {
            return mapToDomainError(authError)
        }
        if let networkError = error as? NetworkError {
            return mapToDomainError(networkError)
        }

        return .unknown
    }

    private func mapToDomainError(_ error: AuthError) -> LoginError {
        switch error {
        case .canceled: .canceled
        case .networkError: .noConnection
        case .missingToken, .unknown: .unknown
        }
    }
    
    private func mapToDomainError(_ error: NetworkError) -> LoginError {
        switch error {
        case .noConnection: .noConnection
        case .forbidden: .forbidden
        case .notFound: .notFound
        case .serverError: .serverError
        case .noData: .noData
        default: .unknown
        }
    }
}
