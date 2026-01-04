//
//  DateFormatter+.swift
//  DSKit
//
//  Created by Youjin Lee on 12/30/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import LivithFoundation

public extension DateFormatter {
    static func formatDateRange(from startDate: Date, to endDate: Date) -> String {
        let calendar = Calendar.current
        let startDateString = DateFormatterFactory.dotDate.string(from: startDate)

        if calendar.isDate(startDate, inSameDayAs: endDate) {
            return startDateString
        }

        let startYear = calendar.component(.year, from: startDate)
        let endYear = calendar.component(.year, from: endDate)

        if startYear == endYear {
            let endShortString = DateFormatterFactory.shortDate.string(from: endDate)
            return "\(startDateString)~\(endShortString)"
        } else {
            let endDateString = DateFormatterFactory.dotDate.string(from: endDate)
            return "\(startDateString)~\(endDateString)"
        }
    }
}
