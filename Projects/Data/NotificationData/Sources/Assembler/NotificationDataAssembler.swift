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

public struct NotificationDataAssembler: DependencyAssembler {
    public init() {}

    public func assemble(to container: any DependencyContainer) {
        registerNotificationRepository(to: container)
    }
}

// MARK: - Repository Registration

private extension NotificationDataAssembler {
    func registerNotificationRepository(to container: any DependencyContainer) {
        let client = container.resolve(NetworkClient.self)
        let notificationRepo = NotificationRepositoryImpl(networkClient: client)

        container.register(notificationRepo, for: NotificationRepository.self)
        container.register(notificationRepo, for: NotificationSettingsRepository.self)
        container.register(notificationRepo, for: NotificationTokenRepository.self)
    }
}
