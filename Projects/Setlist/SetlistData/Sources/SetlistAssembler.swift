//
//  SetlistAssembler.swift
//  SetlistData
//
//  Created by Youjin Lee on 12/30/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import DIContainer
import SetlistDomain

public struct SetlistAssembler: DependencyAssembler {
    public init() {}

    public func assemble(to container: any DependencyContainer) {
        container.register(SetlistRepositoryImpl(), for: SetlistRepository.self)
    }
}
