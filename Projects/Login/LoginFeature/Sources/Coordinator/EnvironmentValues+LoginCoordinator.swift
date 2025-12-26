//
//  EnvironmentValues+LoginCoordinator.swift
//  LoginFeature
//
//  Created by 김진웅 on 12/27/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

private struct LoginCoordinatorKey: EnvironmentKey {
    static let defaultValue: LoginCoordinator? = nil
}

extension EnvironmentValues {
    var loginCoordinator: LoginCoordinator? {
        get { self[LoginCoordinatorKey.self] }
        set { self[LoginCoordinatorKey.self] = newValue }
    }
}
