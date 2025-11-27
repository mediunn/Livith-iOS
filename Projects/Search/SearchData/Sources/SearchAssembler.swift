//
//  SearchAssembler.swift
//  Search
//
//  Created by Youjin Lee on 11/8/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import DIContainer

import SearchDomain

public struct SearchAssembler: DependencyAssembler {
    public init() { }
    
    public func assemble(to container: any DependencyContainer) {
        container.register(SearchRepositoryImpl(), for: SearchRepository.self)
    }
}
