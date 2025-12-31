//
//  ConcertAssembler.swift
//  ConcertData
//
//  Created by Youjin Lee on 12/31/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import DIContainer

import ConcertDomain

public struct ConcertAssembler: DependencyAssembler {
    public init() {}

    public func assemble(to container: any DependencyContainer) {
        container.register(ConcertRepositoryImpl(), for: ConcertRepository.self)
    }
}
