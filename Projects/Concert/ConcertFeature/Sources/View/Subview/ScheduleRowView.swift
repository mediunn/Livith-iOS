//
//  ScheduleRowView.swift
//  ConcertFeature
//
//  Created by Youjin Lee on 12/31/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import ConcertDomain
import DSKit
import LivithFoundation

struct ScheduleRowView: View {

    // MARK: - Property

    let schedule: ConcertSchedule

    // MARK: - Body

    var body: some View {
        LivithScheduleItem(
            daysLeft: daysUntil(schedule.scheduledAt),
            title: schedule.category,
            dateTime: formattedDate,
            isActive: isActive
        )
    }
}

// MARK: - Helpers

private extension ScheduleRowView {
    var formattedDate: String {
        let components = Self.calendar.dateComponents([.hour, .minute], from: schedule.scheduledAt)
        let hasTime = components.hour != 0 || components.minute != 0

        if hasTime {
            return DateFormatterService.string(from: schedule.scheduledAt, type: .koreanDateTime)
        } else {
            return DateFormatterService.string(from: schedule.scheduledAt, type: .koreanDateOnly)
        }
    }

    var isActive: Bool {
        let today = Self.calendar.startOfDay(for: Date())
        let targetDate = Self.calendar.startOfDay(for: schedule.scheduledAt)
        return targetDate >= today
    }

    func daysUntil(_ date: Date) -> Int {
        let today = Self.calendar.startOfDay(for: Date())
        let targetDate = Self.calendar.startOfDay(for: date)
        let components = Self.calendar.dateComponents([.day], from: today, to: targetDate)
        return components.day ?? 0
    }
}

// MARK: - Constants

private extension ScheduleRowView {
    static let calendar = Calendar.current
}

// MARK: - Preview

#Preview {
    VStack(spacing: 34) {
        ScheduleRowView(
            schedule: ConcertSchedule(
                id: 1,
                category: "티켓팅 오픈",
                scheduledAt: Date().addingTimeInterval(86400),
                type: .ticketing
            )
        )
        ScheduleRowView(
            schedule: ConcertSchedule(
                id: 2,
                category: "콘서트 D-DAY",
                scheduledAt: Date(),
                type: .none
            )
        )
        ScheduleRowView(
            schedule: ConcertSchedule(
                id: 3,
                category: "지난 콘서트",
                scheduledAt: Date().addingTimeInterval(-86400 * 3),
                type: .none
            )
        )
    }
    .padding()
    .background(Color.livithColor(.black100))
}
