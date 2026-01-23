//
//  EnvironmentValues+ConcertCoordinator.swift
//  ConcertFeature
//
//  Created by Youjin Lee on 12/31/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

private struct ConcertCoordinatorKey: EnvironmentKey {
    static let defaultValue: ConcertCoordinator? = nil
}

extension EnvironmentValues {
    var concertCoordinator: ConcertCoordinator? {
        get { self[ConcertCoordinatorKey.self] }
        set { self[ConcertCoordinatorKey.self] = newValue }
    }
}
