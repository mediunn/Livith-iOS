//
//  PreferenceDataAssembler.swift
//  PreferenceData
//
//  Created by 김진웅 on 2/4/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import DIContainer
import Domain
import LivithNetwork

public struct PreferenceDataAssembler: DependencyAssembler {
    public init() {}
    
    public func assemble(to container: any DependencyContainer) {
        registerNetwork(to: container)
        registerRepository(to: container)
    }
}

// MARK: - Network Registration

private extension PreferenceDataAssembler {
    func registerNetwork(to container: any DependencyContainer) {
        container.register(PreferenceService(), for: PreferenceService.self)
    }
}

// MARK: - Repository Registration

private extension PreferenceDataAssembler {
    func registerRepository(to container: any DependencyContainer) {
        let preferenceRepo = PreferenceRepositoryImpl(
            preferenceService: container.resolve(PreferenceService.self)
        )
        container.register(preferenceRepo, for: PreferenceRepository.self)
    }
}
