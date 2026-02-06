//
//  NotificationDataAssembler.swift
//  NotificationData
//
//  Created by Youjin Lee on 2/7/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import DIContainer
import Domain
import LivithNetwork
import Persistence

public struct NotificationDataAssembler: DependencyAssembler {
    public init() {}

    public func assemble(to container: any DependencyContainer) {
        registerPersistence(to: container)
        registerNetwork(to: container)
        registerNotificationRepository(to: container)
    }
}

// MARK: - Persistence Registration

private extension NotificationDataAssembler {
    func registerPersistence(to container: any DependencyContainer) {
        container.register(UserDefaultsStorage(), for: UserDefaultsStorage.self)
    }
}

// MARK: - Repository Registration

private extension NotificationDataAssembler {
    func registerNotificationRepository(to container: any DependencyContainer) {
        let notificationRepo = NotificationRepositoryImpl(
            notificationService: container.resolve(NotificationService.self),
            userdefaultsStorage: container.resolve(UserDefaultsStorage.self)
        )

        container.register(notificationRepo, for: NotificationRepository.self)
    }
}

// MARK: - Network Registration

private extension NotificationDataAssembler {
    func registerNetwork(to container: any DependencyContainer) {
        container.register(NotificationService(), for: NotificationService.self)
    }
}
