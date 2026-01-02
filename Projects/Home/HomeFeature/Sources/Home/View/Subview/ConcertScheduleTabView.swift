//
//  ConcertScheduleTabView.swift
//  HomeFeature
//
//  Created by 김진웅 on 1/1/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

import DSKit
import HomeDomain

struct ConcertScheduleTabView: View {
    private let schedules: ConcertScheduleList
    
    init(schedules: ConcertScheduleList) {
        self.schedules = schedules
    }
    
    var body: some View {
        if schedules.isEmpty {
            emptyView()
        } else {
            VStack(alignment: .leading, spacing: 20) {
                Text("날짜와 시간을\n잊지 말고 확인해요")
                    .notosans(.body1Semibold)
                    .foregroundStyle(.livithColor(.white100))
                    .multilineTextAlignment(.leading)
                
                VStack(spacing: .zero) {
                    ForEach(schedules) { schedule in
                        scheduleItem(
                            daysLeft: daysLeftText(from: schedule.schduledAt),
                            title: schedule.category,
                            dateTime: formatDateTime(schedule.schduledAt),
                            isActive: isActiveDate(schedule.schduledAt)
                        )
                        .frame(height: 64)
                    }
                }
                
                Spacer()
                    .frame(minHeight: 280)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 20)
        }
    }
}

// MARK: - Subviews

private extension ConcertScheduleTabView {
    func emptyView() -> some View {
        VStack {
            Spacer()
                .frame(height: 200)
            
            LivithEmptyView(text: "일정이 따로 없어요")
                .frame(maxWidth: .infinity)
            
            Spacer()
                .frame(height: 360)
        }
    }
    
    func scheduleItem(
        daysLeft: String,
        title: String,
        dateTime: String,
        isActive: Bool
    ) -> some View {
        HStack(spacing: 12) {
            daysLeftBadge(daysLeft)
            
            Text(title)
                .notosans(.body3Medium)
                .foregroundStyle(.livithColor(.black30))
            
            Spacer()
            
            Text(dateTime)
                .notosans(.body3Medium)
                .foregroundStyle(.livithColor(.black30))
        }
        .opacity(isActive ? 1.0 : 0.4)
    }
    
    func daysLeftBadge(_ text: String) -> some View {
        Text(text)
            .notosans(.caption1Bold)
            .foregroundStyle(.livithColor(.black100))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(.livithColor(.yellow30))
            )
    }
}

// MARK: - Helpers

private extension ConcertScheduleTabView {
    func daysLeftText(from date: Date) -> String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let targetDate = calendar.startOfDay(for: date)
        let days = calendar.dateComponents([.day], from: today, to: targetDate).day ?? 0
        
        if days == 0 {
            return "D-day"
        } else if days > 0 {
            return "D-\(days)"
        } else {
            return "D+\(abs(days))"
        }
    }
    
    func isActiveDate(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let targetDate = calendar.startOfDay(for: date)
        return targetDate >= today
    }
    
    func formatDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M/d(E) h:mm"
        
        let ampmFormatter = DateFormatter()
        ampmFormatter.locale = Locale(identifier: "en_US")
        ampmFormatter.dateFormat = "a"
        
        return formatter.string(from: date) + ampmFormatter.string(from: date).uppercased()
    }
}
