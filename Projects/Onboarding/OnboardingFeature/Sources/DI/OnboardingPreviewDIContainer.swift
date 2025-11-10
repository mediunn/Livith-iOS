//
//  OnboardingPreviewDIContainer.swift
//  OnboardingFeature
//
//  Created by 김진웅 on 11/10/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import DIContainer
import OnboardingDomain

final class OnboardingPreviewDIContainer: DependencyContainer {
    static let shared = OnboardingPreviewDIContainer()
    
    private var dependencies: [ObjectIdentifier: Any] = [:]
    
    private init() {
        setupDependencies()
    }
    
    func register<T>(_ dependency: T, for type: T.Type) {
        let key = ObjectIdentifier(type)
        dependencies[key] = dependency
    }
    
    func register<T>(_ factory: @escaping () -> T, for type: T.Type) {
        let key = ObjectIdentifier(type)
        dependencies[key] = factory()
    }
    
    func resolve<T>(_ type: T.Type) -> T {
        let key = ObjectIdentifier(type)
        guard let dependency = dependencies[key] as? T else {
            fatalError("\(type) is not registered in OnboardingPreviewDIContainer")
        }
        return dependency
    }
    
    private func setupDependencies() {
        register(MockOnboardingUseCase(), for: OnboardingUseCase.self)
    }
}
