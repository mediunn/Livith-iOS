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

struct OnboardingErrorMapper {
    func mapToDomainError(_ networkError: NetworkError) -> OnboardingError {
        switch networkError {
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
