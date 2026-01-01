//
//  SongAssembler.swift
//  SongData
//
//  Created by Youjin Lee on 1/1/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import DIContainer
import SongDomain

public struct SongAssembler: DependencyAssembler {
    public init() {}

    public func assemble(to container: any DependencyContainer) {
        container.register(SongRepositoryImpl(), for: SongRepository.self)
    }
}
