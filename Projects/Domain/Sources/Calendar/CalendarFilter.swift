//
//  CalendarFilter.swift
//  Domain
//
//  Created by 김진웅 on 7/23/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

// MARK: - Schedule Type Filter

public enum CalendarScheduleTypeFilter: String, CaseIterable, Sendable {
    case ticketing = "TICKETING"
    case concert = "CONCERT"
}

// MARK: - Concert Type Filter

public enum CalendarConcertTypeFilter: String, Sendable {
    case all = "ALL"
    case interest = "INTEREST"
}

public struct CalendarScheduleSelection {
    public enum ToggleResult {
        case changed
        case lastSelectionRequired
    }

    private var selectedTypes = Set(CalendarScheduleTypeFilter.allCases)

    public var scheduleTypes: [CalendarScheduleTypeFilter] {
        CalendarScheduleTypeFilter.allCases.filter(selectedTypes.contains)
    }

    public init() {}

    public func contains(_ type: CalendarScheduleTypeFilter) -> Bool {
        selectedTypes.contains(type)
    }

    public mutating func toggle(_ type: CalendarScheduleTypeFilter) -> ToggleResult {
        if contains(type) {
            guard selectedTypes.count > 1 else { return .lastSelectionRequired }
            selectedTypes.remove(type)
        } else {
            selectedTypes.insert(type)
        }
        return .changed
    }
}
