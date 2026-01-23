//
//  ConcertScheduleTabView.swift
//  HomeFeature
//
//  Created by 김진웅 on 1/1/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

import LivithDesignSystem
import Domain
import LivithFoundation

struct ConcertScheduleTabView: View {
    private let schedules: [ConcertSchedule]

    init(schedules: [ConcertSchedule]) {
        self.schedules = schedules
    }

    var body: some View {
        if schedules.isEmpty {
            emptyView
        } else {
            VStack(alignment: .leading, spacing: 20) {
                Text("날짜와 시간을\n잊지 말고 확인해요")
                    .notosans(.body1Semibold)
                    .foregroundStyle(.livithColor(.white100))
                    .multilineTextAlignment(.leading)

                VStack(spacing: .zero) {
                    ForEach(schedules) { schedule in
                        LivithScheduleItem(
                            daysLeft: daysLeft(from: schedule.scheduledAt),
                            title: schedule.category,
                            dateTime: formatDateTime(schedule.scheduledAt),
                            isActive: isActiveDate(schedule.scheduledAt)
                        )
                        .frame(height: 64)
                    }
                }

                Spacer()
                    .frame(minHeight: 280)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Subviews

private extension ConcertScheduleTabView {
    var emptyView: some View {
        VStack {
            Spacer()
                .frame(height: 200)

            LivithEmptyView(text: "일정이 따로 없어요")
                .frame(maxWidth: .infinity)

            Spacer()
                .frame(height: 360)
        }
    }
}

// MARK: - Helpers

private extension ConcertScheduleTabView {
    func daysLeft(from date: Date) -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let targetDate = calendar.startOfDay(for: date)
        return calendar.dateComponents([.day], from: today, to: targetDate).day ?? 0
    }

    func isActiveDate(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let targetDate = calendar.startOfDay(for: date)
        return targetDate >= today
    }

    func formatDateTime(_ date: Date) -> String {
        DateFormatterService.string(from: date, type: .koreanDateTime)
    }
}
