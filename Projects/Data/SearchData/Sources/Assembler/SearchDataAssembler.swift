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
import LivithNetwork

public struct SearchDataAssembler: DependencyAssembler {
    public init() {}
    
    public func assemble(to container: any DependencyContainer) {
        registerNetwork(to: container)
        registerSearchRepository(to: container)
    }
}

// MARK: - Repository Registration

private extension SearchDataAssembler {
    func registerSearchRepository(to container: any DependencyContainer) {
        let searchRepo = SearchRepositoryImpl(
            searchService: container.resolve(SearchService.self)
        )
        container.register(searchRepo, for: SearchRepository.self)
    }
}

// MARK: - Network Registration

private extension SearchDataAssembler {
    func registerNetwork(to container: any DependencyContainer) {
        container.register(SearchService(), for: SearchService.self)
    }
}
