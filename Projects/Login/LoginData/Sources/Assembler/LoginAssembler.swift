//
//  LoginAssembler.swift
//  LoginData
//
//  Created by 김진웅 on 12/3/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import DIContainer
import LoginDomain

public struct LoginAssembler: DependencyAssembler {
    public init() {}
    
    public func assemble(to container: DependencyContainer) {
        container.register({
            LoginUseCaseImpl(repository: LoginRepositoryImpl())
        }, for: LoginUseCase.self)
        
        container.register({
            OnboardingUseCaseImpl(onboardingRepository: OnboardingRepositoryImpl())
        }, for: OnboardingUseCase.self)
    }
}
