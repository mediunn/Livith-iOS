//
//  OnboardingUseCase.swift
//  LoginDomain
//
//  Created by 김진웅 on 11/10/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

public protocol OnboardingUseCase {
    func validateNicknameFormat(_ nickname: String) throws(OnboardingError)
    func checkNicknameDuplicate(_ nickname: String) async throws(OnboardingError)
    func signup(marketingConsent: Bool, nickname: String, tempUser: TempUser) async throws(OnboardingError)
}

public final class OnboardingUseCaseImpl: OnboardingUseCase {
    private let onboardingRepository: OnboardingRepository
    
    public init(onboardingRepository: OnboardingRepository) {
        self.onboardingRepository = onboardingRepository
    }
    
    public func validateNicknameFormat(_ nickname: String) throws(OnboardingError) {
        let pattern = /^[a-zA-Z0-9가-힣]{1,10}$/
        
        guard (nickname.wholeMatch(of: pattern) != nil) else {
            throw OnboardingError.invalidNicknameFormat
        }
    }
    
    public func checkNicknameDuplicate(_ nickname: String) async throws(OnboardingError) {
        let isAvailable = try await onboardingRepository.checkNicknameDuplicate(nickname)
        
        if !isAvailable {
            throw OnboardingError.nicknameDuplicated
        }
    }
    
    public func signup(marketingConsent: Bool, nickname: String, tempUser: TempUser) async throws(OnboardingError) {
        try await onboardingRepository.signup(
            marketingConsent: marketingConsent,
            nickname: nickname,
            tempUser: tempUser
        )
    }
}
