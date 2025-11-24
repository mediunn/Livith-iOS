//
//  OnboardingAssembler.swift
//  OnboardingFeature
//
//  Created by 김진웅 on 11/10/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import DIContainer
import OnboardingDomain

public struct OnboardingAssembler: DependencyAssembler {
    public init() {}
    
    public func assemble(to container: DependencyContainer) {
        let onboardingRepository = container.resolve(OnboardingRepository.self)

        container.register(
            OnboardingUseCaseImpl(onboardingRepository: onboardingRepository),
            for: OnboardingUseCase.self
        )
    }
}
