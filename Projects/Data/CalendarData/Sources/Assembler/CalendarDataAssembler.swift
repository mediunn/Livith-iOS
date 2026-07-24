//
//  CalendarDataAssembler.swift
//  CalendarData
//
//  Created by 김진웅 on 7/23/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import DIContainer
import Domain
import LivithNetworking

public struct CalendarDataAssembler: DependencyAssembler {
    public init() {}

    public func assemble(to container: any DependencyContainer) {
        registerCalendarRepository(to: container)
    }
}

// MARK: - Repository Registration

private extension CalendarDataAssembler {
    func registerCalendarRepository(to container: any DependencyContainer) {
        let client = container.resolve(NetworkClient.self)
        let calendarRepo = CalendarRepositoryImpl(networkClient: client)
        container.register(calendarRepo, for: CalendarRepository.self)
    }
}
