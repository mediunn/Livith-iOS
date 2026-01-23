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
import LivithNetwork

public struct SetlistDataAssembler: DependencyAssembler {
    public init() {}
    
    public func assemble(to container: any DependencyContainer) {
        registerNetwork(to: container)
        registerSetlistRepository(to: container)
    }
}

// MARK: - Repository Registration

private extension SetlistDataAssembler {
    func registerSetlistRepository(to container: any DependencyContainer) {
        let setlistRepo = SetlistRepositoryImpl(
            setlistService: container.resolve(SetlistService.self)
        )
        container.register(setlistRepo, for: SetlistRepository.self)
    }
}

// MARK: - Network Registration

private extension SetlistDataAssembler {
    func registerNetwork(to container: any DependencyContainer) {
        container.register(SetlistService(), for: SetlistService.self)
    }
}
