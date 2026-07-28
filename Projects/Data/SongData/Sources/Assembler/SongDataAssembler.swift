//
//  SongDataAssembler.swift
//  SongData
//
//  Created by 김진웅 on 1/23/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import DIContainer
import Domain
import LivithNetworking

public struct SongDataAssembler: DependencyAssembler {
    public init() {}
    
    public func assemble(to container: any DependencyContainer) {
        registerSongRepository(to: container)
    }
}

// MARK: - Repository Registration

private extension SongDataAssembler {
    func registerSongRepository(to container: any DependencyContainer) {
        let client = container.resolve(NetworkClient.self)
        let songRepo = SongRepositoryImpl(
            networkClient: client
        )
        container.register(songRepo, for: SongRepository.self)
    }
}
