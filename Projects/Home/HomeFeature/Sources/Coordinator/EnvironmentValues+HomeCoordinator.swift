//
//  EnvironmentValues+HomeCoordinator.swift
//  HomeFeature
//
//  Created by 김진웅 on 12/27/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

private struct HomeCoordinatorKey: EnvironmentKey {
    static let defaultValue: HomeCoordinator? = nil
}

extension EnvironmentValues {
    var homeCoordinator: HomeCoordinator? {
        get { self[HomeCoordinatorKey.self] }
        set { self[HomeCoordinatorKey.self] = newValue }
    }
}
