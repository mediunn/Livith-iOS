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

struct ScheduleRowView: View {

    // MARK: - Property

    let schedule: ConcertSchedule

    // MARK: - Body

    var body: some View {
        HStack(spacing: 8) {
            dDayChip

            Text(schedule.category)
                .notosans(.body3Medium)
                .foregroundStyle(Color.livithColor(.white100))

            Spacer()

            Text(formattedDate)
                .notosans(.body3Medium)
                .foregroundStyle(Color.livithColor(.white100))
        }
    }
}

// MARK: - Subviews

private extension ScheduleRowView {
    var dDayChip: some View {
        let days = daysUntil(schedule.scheduledAt)

        if days > 0 {
            return ConcertStatusChip(statusText: "D-", remainDays: days, isHighlighted: true)
        } else if days == 0 {
            return ConcertStatusChip(statusText: "D-DAY", isHighlighted: true)
        } else {
            return ConcertStatusChip(statusText: "D+\(abs(days))", isHighlighted: true)
        }
    }

    var formattedDate: String {
        Self.dateFormatter.string(from: schedule.scheduledAt)
    }

    func daysUntil(_ date: Date) -> Int {
        let today = Self.calendar.startOfDay(for: Date())
        let targetDate = Self.calendar.startOfDay(for: date)
        let components = Self.calendar.dateComponents([.day], from: today, to: targetDate)
        return components.day ?? 0
    }
}

// MARK: - Cached Formatters

private extension ScheduleRowView {
    static let calendar = Calendar.current

    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M/d(E) h:mma"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        return formatter
    }()
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
