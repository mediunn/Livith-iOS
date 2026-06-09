//
//  SearchDataAssembler.swift
//  SearchData
//
//  Created by 김진웅 on 1/23/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import DIContainer
import Domain
import LivithNetworking

public struct SearchDataAssembler: DependencyAssembler {
    public init() {}
    
    public func assemble(to container: any DependencyContainer) {
        registerSearchRepository(to: container)
    }
}

// MARK: - Repository Registration

private extension SearchDataAssembler {
    func registerSearchRepository(to container: any DependencyContainer) {
        let client = container.resolve(NetworkClient.self)
        let searchRepo = SearchRepositoryImpl(
            networkClient: client
        )
        container.register(searchRepo, for: SearchRepository.self)
    }
}
