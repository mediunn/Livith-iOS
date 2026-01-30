//
//  LivithWidgetEntry.swift
//  LivithWidget
//
//  Created by Youjin Lee on 1/15/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import WidgetKit
import Foundation

struct LivithWidgetEntry: TimelineEntry {
    let date: Date
    let concertID: Int?
    let posterImageData: Data?
    let artistName: String?
    let concertTitle: String?
    let dDay: Int?
    let startDate: Date?
    let endDate: Date?
    let venue: String?
    let schedules: [ScheduleItem]

    var hasData: Bool { concertID != nil }

    var formattedDDay: String? {
        guard let dDay = dDay else { return nil }
        if dDay > 0 {
            return "D-\(dDay)"
        } else if dDay == 0 {
            return "D-Day"
        } else {
            return "D+\(abs(dDay))"
        }
    }

    var concertDate: String? {
        guard let startDate = startDate else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: startDate)
    }

    var concertDateRange: String? {
        guard let startDate = startDate else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        let start = formatter.string(from: startDate)
        if let endDate = endDate {
            let end = formatter.string(from: endDate)
            return start == end ? start : "\(start) ~\(end)"
        }
        return start
    }

    static let placeholder = LivithWidgetEntry(
        date: Date(),
        concertID: nil,
        posterImageData: nil,
        artistName: nil,
        concertTitle: nil,
        dDay: nil,
        startDate: nil,
        endDate: nil,
        venue: nil,
        schedules: []
    )

    static let preview = LivithWidgetEntry(
        date: Date(),
        concertID: 1,
        posterImageData: nil,
        artistName: "아이유",
        concertTitle: "2026 IU CONCERT",
        dDay: 15,
        startDate: Date().addingTimeInterval(86400 * 15),
        endDate: Date().addingTimeInterval(86400 * 16),
        venue: "올림픽공원 올림픽홀",
        schedules: [
            ScheduleItem(id: 1, category: "1일차 콘서트", scheduledAt: "2026-01-30T14:00:00", dDay: 15),
            ScheduleItem(id: 2, category: "2일차 콘서트", scheduledAt: "2026-01-31T14:00:00", dDay: 16),
            ScheduleItem(id: 3, category: "3일차 콘서트", scheduledAt: "2026-02-01T14:00:00", dDay: 17)
        ]
    )
}


