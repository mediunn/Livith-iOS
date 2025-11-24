//
//  OnboardingErrorMapper.swift
//  OnboardingData
//
//  Created by 김진웅 on 11/10/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import LivithNetwork
import OnboardingDomain

struct OnboardingErrorMapper {
    func mapToOnboardingError(_ networkError: NetworkError) -> OnboardingError {
        switch networkError {
        case .badRequest(let message):
            guard let message = message else {
                return .unknown
            }
            
            if message == Literals.duplicateNicknameMessage {
                return .nicknameDuplicated
            }
            
            if message == Literals.invalidNicknameLengthMessage {
                return .invalidNicknameFormat
            }
            
            return .unknown
            
        case .notFound(let message):
            if message == Literals.userNotFoundMessage {
                return .unknown
            }
            return .unknown
        
        case .noConnection:
            return .networkError
            
        case .invalidResponse, .noData:
            return .networkError
        
        default:
            return .unknown
        }
    }
}

// MARK: - Literals

private extension OnboardingErrorMapper {
    enum Literals {
        static let duplicateNicknameMessage = "이미 존재하는 닉네임이에요."
        static let invalidNicknameLengthMessage = "nickname must be shorter than or equal to 10 characters"
        static let userNotFoundMessage = "해당 유저가 존재하지 않습니다."
    }
}