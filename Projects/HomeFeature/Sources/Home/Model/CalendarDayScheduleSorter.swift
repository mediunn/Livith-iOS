//
//  CalendarDayScheduleSorter.swift
//  HomeFeature
//
//  Created by 김진웅 on 7/19/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

enum CalendarDayScheduleSorter {
    static func sorted(_ itemList: [CalendarDayScheduleItem]) -> [CalendarDayScheduleItem] {
        itemList.sorted { lhs, rhs in
            let lhsRank = sortRank(lhs)
            let rhsRank = sortRank(rhs)
            if lhsRank != rhsRank {
                return lhsRank < rhsRank
            }

            if lhsRank == 0, let lhsTime = lhs.time, let rhsTime = rhs.time, lhsTime != rhsTime {
                return lhsTime < rhsTime
            }

            return lhs.title.localizedStandardCompare(rhs.title) == .orderedAscending
        }
    }

    private static func sortRank(_ item: CalendarDayScheduleItem) -> Int {
        if item.isCancelled {
            return 2
        }
        if item.time == nil {
            return 1
        }
        return 0
    }
}
