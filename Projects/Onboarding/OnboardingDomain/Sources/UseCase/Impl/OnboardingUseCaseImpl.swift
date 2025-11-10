//
//  OnboardingUseCaseImpl.swift
//  OnboardingDomain
//
//  Created by 김진웅 on 11/10/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

public final class OnboardingUseCaseImpl: OnboardingUseCase {
    private let onboardingRepository: OnboardingRepository
    
    public init(onboardingRepository: OnboardingRepository) {
        self.onboardingRepository = onboardingRepository
    }
    
    public func validateNicknameFormat(_ nickname: String) throws(OnboardingError) {
        let pattern = "^[a-zA-Z0-9가-힣]{1,10}$"
        let isValid = nickname.range(of: pattern, options: .regularExpression) != nil
        
        if !isValid {
            throw OnboardingError.invalidNicknameFormat
        }
    }
    
    public func checkNicknameDuplicate(_ nickname: String) async throws(OnboardingError) {
        try await onboardingRepository.checkNicknameDuplicate(nickname)
    }
    
    public func signup(nickname: String) async throws(OnboardingError) {
        try await onboardingRepository.signup(nickname: nickname)
    }
}
