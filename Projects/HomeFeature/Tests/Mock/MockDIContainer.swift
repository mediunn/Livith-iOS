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

final class MockDIContainer {
    let userRepository = MockUserRepository()
    let notificationRepository = MockNotificationRepository()
    let concertRepository = MockConcertRepository()
    let searchRepository = MockSearchRepository()
    let setlistRepository = MockSetlistRepository()
    let preferenceRepository = MockPreferenceRepository()
    
    func registerDependencies() {
        DIContainer.shared.register(userRepository, for: UserRepository.self)
        DIContainer.shared.register(notificationRepository, for: NotificationRepository.self)
        DIContainer.shared.register(concertRepository, for: ConcertRepository.self)
        DIContainer.shared.register(searchRepository, for: SearchRepository.self)
        DIContainer.shared.register(setlistRepository, for: SetlistRepository.self)
        DIContainer.shared.register(preferenceRepository, for: PreferenceRepository.self)
    }
}
