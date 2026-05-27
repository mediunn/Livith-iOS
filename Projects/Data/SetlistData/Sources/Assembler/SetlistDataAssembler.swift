//
//  SetlistDataAssembler.swift
//  SetlistData
//
//  Created by 김진웅 on 1/23/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import DIContainer
import Domain
import LivithNetworking

public struct SetlistDataAssembler: DependencyAssembler {
    public init() {}
    
    public func assemble(to container: any DependencyContainer) {
        registerSetlistRepository(to: container)
    }
}

// MARK: - Repository Registration

private extension SetlistDataAssembler {
    func registerSetlistRepository(to container: any DependencyContainer) {
        let factory = container.resolve(NetworkingFactory.self)
        let setlistRepo = SetlistRepositoryImpl(
            setlistService: factory.makeSetlistService()
        )
        container.register(setlistRepo, for: SetlistRepository.self)
    }
}
