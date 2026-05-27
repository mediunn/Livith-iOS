//
//  ConcertDataAssembler.swift
//  ConcertData
//
//  Created by 김진웅 on 1/23/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import DIContainer
import Domain
import LivithNetworking

public struct ConcertDataAssembler: DependencyAssembler {
    public init() {}
    
    public func assemble(to container: any DependencyContainer) {
        registerConcertRepository(to: container)
    }
}

// MARK: - Repository Registration

private extension ConcertDataAssembler {
    func registerConcertRepository(to container: any DependencyContainer) {
        let factory = container.resolve(NetworkingFactory.self)
        let concertRepo = ConcertRepositoryImpl(
            homeService: factory.makeHomeService(),
            searchService: factory.makeSearchService(),
            concertService: factory.makeConcertService(),
            setlistService: factory.makeSetlistService()
        )
        container.register(concertRepo, for: ConcertRepository.self)
    }
}
