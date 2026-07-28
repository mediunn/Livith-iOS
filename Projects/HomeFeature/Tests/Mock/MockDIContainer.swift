//
//  MockDIContainer.swift
//  HomeFeatureTests
//
//  Created by 김진웅 on 2/5/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import DIContainer
import Domain

@testable import HomeFeature

final class MockDIContainer {
    let userRepository = MockUserRepository()
    let notificationRepository = MockNotificationRepository()
    let concertRepository = MockConcertRepository()
    let searchRepository = MockSearchRepository()
    let setlistRepository = MockSetlistRepository()
    let preferenceRepository = MockPreferenceRepository()
    let calendarRepository = MockCalendarRepository()
    let concertMatchingRepository = MockConcertMatchingRepository()

    func registerDependencies() {
        DIContainer.shared.register(userRepository, for: UserRepository.self)
        DIContainer.shared.register(notificationRepository, for: NotificationRepository.self)
        DIContainer.shared.register(concertRepository, for: ConcertRepository.self)
        DIContainer.shared.register(searchRepository, for: SearchRepository.self)
        DIContainer.shared.register(setlistRepository, for: SetlistRepository.self)
        DIContainer.shared.register(preferenceRepository, for: PreferenceRepository.self)
        DIContainer.shared.register(calendarRepository, for: CalendarRepository.self)
        DIContainer.shared.register(concertMatchingRepository, for: ConcertMatchingRepository.self)
        DIContainer.shared.register(CalendarWebConfig(url: nil), for: CalendarWebConfig.self)
    }
}
