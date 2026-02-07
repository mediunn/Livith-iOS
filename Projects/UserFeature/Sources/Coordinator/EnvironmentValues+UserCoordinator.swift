//
//  EnvironmentValues+UserCoordinator.swift
//  UserFeature
//
//  Created by 김진웅 on 2/7/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

private struct UserCoordinatorKey: EnvironmentKey {
    static let defaultValue: UserCoordinator? = nil
}

extension EnvironmentValues {
    var userCoordinator: UserCoordinator? {
        get { self[UserCoordinatorKey.self] }
        set { self[UserCoordinatorKey.self] = newValue }
    }
}
