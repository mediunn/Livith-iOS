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
import LivithNetwork
import Persistence

public struct UserDataAssembler: DependencyAssembler {
    public init() {}
    
    public func assemble(to container: any DependencyContainer) {
        registerPersistence(to: container)
        registerNetwork(to: container)
        registerUserRepository(to: container)
    }
}

// MARK: - Repository Registration

private extension UserDataAssembler {
    func registerUserRepository(to container: any DependencyContainer) {
        let userRepo = UserRepositoryImpl(
            onboardingService: container.resolve(OnboardingService.self),
            homeService: container.resolve(HomeService.self),
            userService: container.resolve(UserService.self),
            userdefaultsStorage: container.resolve(UserDefaultsStorage.self),
            widgetImageStorage: container.resolve(WidgetImageStorage.self)
        )
        container.register(userRepo, for: UserRepository.self)
    }
}

// MARK: - Persistence Registration

private extension UserDataAssembler {
    func registerPersistence(to container: any DependencyContainer) {
        container.register(UserDefaultsStorage(), for: UserDefaultsStorage.self)
        container.register(WidgetImageStorage(), for: WidgetImageStorage.self)
    }
}

// MARK: - Network Registration

private extension UserDataAssembler {
    func registerNetwork(to container: any DependencyContainer) {
        container.register(HomeService(), for: HomeService.self)
        container.register(UserService(), for: UserService.self)
        container.register(OnboardingService(), for: OnboardingService.self)
    }
}
