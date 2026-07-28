//
//  UserDataAssembler.swift
//  UserData
//
//  Created by 김진웅 on 1/23/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import DIContainer
import Domain
import LivithNetworking
import Persistence

public struct UserDataAssembler: DependencyAssembler {
    public init() {}
    
    public func assemble(to container: any DependencyContainer) {
        registerPersistence(to: container)
        registerUserRepository(to: container)
        registerConcertMatchingRepository(to: container)
    }
}

// MARK: - Repository Registration

private extension UserDataAssembler {
    func registerUserRepository(to container: any DependencyContainer) {
        let client = container.resolve(NetworkClient.self)
        let userRepo = UserRepositoryImpl(
            networkClient: client,
            userdefaultsStorage: container.resolve(UserDefaultsStorage.self)
        )
        
        container.register(userRepo, for: UserRepository.self)
    }

    func registerConcertMatchingRepository(to container: any DependencyContainer) {
        let client = container.resolve(NetworkClient.self)
        container.register(
            ConcertMatchingRepositoryImpl(networkClient: client),
            for: ConcertMatchingRepository.self
        )
    }
}

// MARK: - Persistence Registration

private extension UserDataAssembler {
    func registerPersistence(to container: any DependencyContainer) {
        container.register(UserDefaultsStorage(), for: UserDefaultsStorage.self)
    }
}
