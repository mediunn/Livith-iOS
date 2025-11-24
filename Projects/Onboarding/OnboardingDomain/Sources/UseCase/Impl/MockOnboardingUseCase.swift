//
//  MockOnboardingUseCase.swift
//  OnboardingDomain
//
//  Created by 김진웅 on 11/10/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

public final class MockOnboardingUseCase: OnboardingUseCase {
    public init() {}
    
    public func validateNicknameFormat(_ nickname: String) throws(OnboardingError) {
        let pattern = "^[a-zA-Z0-9가-힣]{1,10}$"
        let isValid = nickname.range(of: pattern, options: .regularExpression) != nil
        
        if !isValid {
            throw OnboardingError.invalidNicknameFormat
        }
    }
    
    public func checkNicknameDuplicate(_ nickname: String) async throws(OnboardingError) {
        do {
            try await Task.sleep(for: .seconds(1))
        } catch {
            throw OnboardingError.networkError
        }
        
        let isDuplicate = nickname == "test"
        if isDuplicate {
            throw OnboardingError.nicknameDuplicated
        }
    }
    
    public func signup(nickname: String) async throws(OnboardingError) {
        do {
            try await Task.sleep(for: .seconds(1))
        } catch {
            throw OnboardingError.networkError
        }
        
        if nickname == "fail" {
            throw OnboardingError.signupFailed(reason: "서버 오류")
        }
    }
}
