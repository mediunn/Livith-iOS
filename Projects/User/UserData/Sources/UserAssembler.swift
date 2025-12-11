//
//  UserAssembler.swift
//  User
//
//  Created by Youjin Lee on 12/11/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import DIContainer
import UserDomain

public struct UserAssembler: DependencyAssembler {
    public init() { }
    
    public func assemble(to container: any DependencyContainer) {
        container.register(UserRepositoryImpl(), for: UserRepository.self)
    }
}
