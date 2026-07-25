//
//  MockDIContainer.swift
//  ShareFeatureTests
//
//  Created by Youjin Lee on 7/24/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import DIContainer
import Domain

final class MockDIContainer {
    let concertRepository = MockConcertRepository()

    func registerDependencies() {
        DIContainer.shared.register(concertRepository, for: ConcertRepository.self)
    }
}
