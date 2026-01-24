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
import LivithNetwork

public struct SongDataAssembler: DependencyAssembler {
    public init() {}
    
    public func assemble(to container: any DependencyContainer) {
        registerNetwork(to: container)
        registerSongRepository(to: container)
    }
}

// MARK: - Repository Registration

private extension SongDataAssembler {
    func registerSongRepository(to container: any DependencyContainer) {
        let songRepo = SongRepositoryImpl(
            songService: container.resolve(SongService.self)
        )
        container.register(songRepo, for: SongRepository.self)
    }
}

// MARK: - Network Registration

private extension SongDataAssembler {
    func registerNetwork(to container: any DependencyContainer) {
        container.register(SongService(), for: SongService.self)
    }
}
