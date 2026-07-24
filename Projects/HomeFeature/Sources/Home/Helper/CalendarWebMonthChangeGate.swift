//
//  CalendarWebMonthChangeGate.swift
//  HomeFeature
//
//  Created by 김진웅 on 7/25/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

struct CalendarWebMonthChangeGate {

    // MARK: - Properties

    private(set) var hasCompletedInitialInject = false

    // MARK: - Methods

    mutating func markInjectSucceeded() {
        hasCompletedInitialInject = true
    }

    mutating func reset() {
        hasCompletedInitialInject = false
    }

    var shouldAcceptMonthChanged: Bool {
        hasCompletedInitialInject
    }
}
