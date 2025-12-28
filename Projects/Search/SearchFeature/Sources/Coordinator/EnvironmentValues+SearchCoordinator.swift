//
//  EnvironmentValues+SearchCoordinator.swift
//  SearchFeature
//
//  Created by 김진웅 on 12/27/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

private struct SearchCoordinatorKey: EnvironmentKey {
    static let defaultValue: SearchCoordinator? = nil
}

extension EnvironmentValues {
    var searchCoordinator: SearchCoordinator? {
        get { self[SearchCoordinatorKey.self] }
        set { self[SearchCoordinatorKey.self] = newValue }
    }
}
