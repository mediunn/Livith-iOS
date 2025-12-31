//
//  DateFormatter+DateRange.swift
//  ConcertFeature
//
//  Created by Youjin Lee on 12/31/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

extension DateFormatter {
    static let fullDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter
    }()

    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM.dd"
        return formatter
    }()

    static func formatDateRange(from startDate: Date, to endDate: Date) -> String {
        let calendar = Calendar.current
        let startDateString = fullDate.string(from: startDate)

        if calendar.isDate(startDate, inSameDayAs: endDate) {
            return startDateString
        }

        let startYear = calendar.component(.year, from: startDate)
        let endYear = calendar.component(.year, from: endDate)

        if startYear == endYear {
            let endShortString = shortDate.string(from: endDate)
            return "\(startDateString)~\(endShortString)"
        } else {
            let endDateString = fullDate.string(from: endDate)
            return "\(startDateString)~\(endDateString)"
        }
    }
}
