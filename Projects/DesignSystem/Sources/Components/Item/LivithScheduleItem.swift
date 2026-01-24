//
//  LivithScheduleItem.swift
//  LivithDesignSystem
//
//  Created by Youjin Lee on 1/6/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

// MARK: - LivithScheduleItem

public struct LivithScheduleItem: View {

    // MARK: - Property

    private let daysLeft: Int
    private let title: String
    private let dateTime: String
    private let isActive: Bool

    // MARK: - Initializer

    public init(
        daysLeft: Int,
        title: String,
        dateTime: String,
        isActive: Bool = true
    ) {
        self.daysLeft = daysLeft
        self.title = title
        self.dateTime = dateTime
        self.isActive = isActive
    }

    // MARK: - Body

    public var body: some View {
        HStack(spacing: 12) {
            dDayBadge

            Text(title)
                .notosans(.body3Medium)
                .foregroundStyle(Color.livithColor(.white100))

            Spacer()

            Text(dateTime)
                .notosans(.body3Medium)
                .foregroundStyle(Color.livithColor(.white100))
        }
        .overlay {
            if !isActive {
                Color.livithColor(.black100).opacity(0.4)
            }
        }
    }
}

// MARK: - Subviews

private extension LivithScheduleItem {
    var dDayBadge: some View {
        Text(dDayText)
            .notosans(.caption1Bold)
            .foregroundStyle(Color.livithColor(.black100))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(Color.livithColor(.yellow30))
            )
    }

    var dDayText: String {
        if daysLeft > 0 {
            return "D-\(daysLeft)"
        } else if daysLeft == 0 {
            return "D-day"
        } else {
            return "D+\(abs(daysLeft))"
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        LivithScheduleItem(
            daysLeft: 3,
            title: "1일차 콘서트",
            dateTime: "9/13(토) 2:00PM"
        )

        LivithScheduleItem(
            daysLeft: 0,
            title: "D-DAY 콘서트",
            dateTime: "9/14(일) 2:00PM"
        )

        LivithScheduleItem(
            daysLeft: -2,
            title: "지난 콘서트",
            dateTime: "9/12(금) 2:00PM",
            isActive: false
        )
    }
    .padding(.horizontal, 16)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.livithColor(.black100))
}
