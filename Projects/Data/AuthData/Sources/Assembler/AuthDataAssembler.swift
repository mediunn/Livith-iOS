//
//  AuthDataAssembler.swift
//  AuthData
//
//  Created by 김진웅 on 1/23/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import DIContainer
import Domain
import LivithNetworking
import Persistence
import SocialAuth

public struct AuthDataAssembler: DependencyAssembler {
    public init() {}
    
    public func assemble(to container: any DependencyContainer) {
        registerPersistence(to: container)
        registerSocialAuth(to: container)
        registerAuthRepository(to: container)
    }
}

// MARK: - Repository Registration

private extension AuthDataAssembler {
    func registerAuthRepository(to container: any DependencyContainer) {
        let factory = container.resolve(NetworkingFactory.self)
        let authRepo = AuthRepositoryImpl(
            socialAuthService: container.resolve(SocialAuthService.self),
            onboardingService: factory.makeOnboardingService(),
            userService: factory.makeUserService(),
            notificationRepository: container.resolve(NotificationRepository.self),
            userdefaultsStorage: container.resolve(UserDefaultsStorage.self),
            tokenStore: factory.makeTokenStore()
        )
        container.register(authRepo, for: AuthRepository.self)
    }
}

// MARK: - Persistence Registration

private extension AuthDataAssembler {
    func registerPersistence(to container: any DependencyContainer) {
        container.register(UserDefaultsStorage(), for: UserDefaultsStorage.self)
    }
}

// MARK: - SocialAuth Registration

private extension AuthDataAssembler {
    func registerSocialAuth(to container: any DependencyContainer) {
        container.register(SocialAuthService(), for: SocialAuthService.self)
    }
}
