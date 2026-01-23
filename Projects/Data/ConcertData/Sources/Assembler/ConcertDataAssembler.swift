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
import LivithNetwork

public struct ConcertDataAssembler: DependencyAssembler {
    public init() {}
    
    public func assemble(to container: any DependencyContainer) {
        registerNetwork(to: container)
        registerConcertRepository(to: container)
    }
}

// MARK: - Repository Registration

private extension ConcertDataAssembler {
    func registerConcertRepository(to container: any DependencyContainer) {
        let concertRepo = ConcertRepositoryImpl(
            homeService: container.resolve(HomeService.self),
            searchService: container.resolve(SearchService.self),
            concertService: container.resolve(ConcertService.self),
            setlistService: container.resolve(SetlistService.self)
        )
        container.register(concertRepo, for: ConcertRepository.self)
    }
}

// MARK: - Network Registration

private extension ConcertDataAssembler {
    func registerNetwork(to container: any DependencyContainer) {
        container.register(HomeService(), for: HomeService.self)
        container.register(SearchService(), for: SearchService.self)
        container.register(ConcertService(), for: ConcertService.self)
        container.register(SetlistService(), for: SetlistService.self)
    }
}
