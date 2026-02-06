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
import LivithNetwork
import Persistence
import SocialAuth

public struct AuthDataAssembler: DependencyAssembler {
    public init() {}
    
    public func assemble(to container: any DependencyContainer) {
        registerPersistence(to: container)
        registerNetwork(to: container)
        registerSocialAuth(to: container)
        registerAuthRepository(to: container)
    }
}

// MARK: - Repository Registration

private extension AuthDataAssembler {
    func registerAuthRepository(to container: any DependencyContainer) {
        let authRepo = AuthRepositoryImpl(
            socialAuthService: container.resolve(SocialAuthService.self),
            onboardingService: container.resolve(OnboardingService.self),
            userService: container.resolve(UserService.self),
            notificationService: container.resolve(NotificationService.self),
            userdefaultsStorage: container.resolve(UserDefaultsStorage.self),
            tokenService: container.resolve(TokenService.self),
            widgetImageStorage: container.resolve(WidgetImageStorage.self)
        )
        container.register(authRepo, for: AuthRepository.self)
    }
}

// MARK: - Persistence Registration

private extension AuthDataAssembler {
    func registerPersistence(to container: any DependencyContainer) {
        container.register(UserDefaultsStorage(), for: UserDefaultsStorage.self)
        container.register(WidgetImageStorage(), for: WidgetImageStorage.self)
    }
}

// MARK: - SocialAuth Registration

private extension AuthDataAssembler {
    func registerSocialAuth(to container: any DependencyContainer) {
        container.register(SocialAuthService(), for: SocialAuthService.self)
    }
}

// MARK: - Network Registration

private extension AuthDataAssembler {
    func registerNetwork(to container: any DependencyContainer) {
        container.register(TokenServiceImpl(), for: TokenService.self)
        container.register(UserService(), for: UserService.self)
        container.register(OnboardingService(), for: OnboardingService.self)
        container.register(NotificationService(), for: NotificationService.self)
    }
}
