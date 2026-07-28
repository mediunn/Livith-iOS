//
//  MockDIContainer.swift
//  PreferenceFeatureTests
//
//  Created by 김진웅 on 2/4/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import DIContainer
import Domain

final class MockDIContainer {
    let preferenceRepository = MockPreferenceRepository()
    
    func registerDependencies() {
        DIContainer.shared.register(preferenceRepository, for: PreferenceRepository.self)
    }
}
