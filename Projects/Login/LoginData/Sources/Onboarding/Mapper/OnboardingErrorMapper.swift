//
//  OnboardingErrorMapper.swift
//  LoginData
//
//  Created by 김진웅 on 11/10/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import LivithNetwork
import LoginDomain
import Persistence

struct OnboardingErrorMapper {
    func mapToDomainError(_ error: Error) -> OnboardingError {
        if let networkError = error as? NetworkError {
            return mapToDomainError(networkError)
        }

        if error is StorageError {
            return .unknown
        }
        
        return .unknown
    }

    private func mapToDomainError(_ error: NetworkError) -> OnboardingError {
        switch error {
        case .serverError:
            return .serverError
        case .noConnection:
            return .noConnection
        case .badRequest:
            return .invalidNicknameFormat
        default:
            return .unknown
        }
    }
}
