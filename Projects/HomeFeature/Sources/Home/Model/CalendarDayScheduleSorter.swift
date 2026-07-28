//
//  CalendarDayScheduleSorter.swift
//  HomeFeature
//
//  Created by 김진웅 on 7/19/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain

enum CalendarDayScheduleSorter {
    static func sorted(_ eventList: [CalendarDayEvent]) -> [CalendarDayEvent] {
        eventList.sorted { lhs, rhs in
            let lhsRank = sortRank(lhs)
            let rhsRank = sortRank(rhs)
            if lhsRank != rhsRank {
                return lhsRank < rhsRank
            }

            if lhsRank == 0, let lhsTime = lhs.time, let rhsTime = rhs.time, lhsTime != rhsTime {
                return lhsTime < rhsTime
            }

            return lhs.displayTitle.localizedStandardCompare(rhs.displayTitle) == .orderedAscending
        }
    }

    private static func sortRank(_ event: CalendarDayEvent) -> Int {
        if event.isCancelled {
            return 2
        }
        if event.time == nil {
            return 1
        }
        return 0
    }
}
