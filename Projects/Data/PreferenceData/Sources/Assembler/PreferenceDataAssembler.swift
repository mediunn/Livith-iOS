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
import LivithNetworking

public struct PreferenceDataAssembler: DependencyAssembler {
    public init() {}
    
    public func assemble(to container: any DependencyContainer) {
        registerRepository(to: container)
    }
}

// MARK: - Repository Registration

private extension PreferenceDataAssembler {
    func registerRepository(to container: any DependencyContainer) {
        let factory = container.resolve(NetworkingFactory.self)
        let preferenceRepo = PreferenceRepositoryImpl(
            preferenceService: factory.makePreferenceService()
        )
        container.register(preferenceRepo, for: PreferenceRepository.self)
    }
}
