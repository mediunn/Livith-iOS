//
//  CalendarDayScheduleItemRow.swift
//  HomeFeature
//
//  Created by 김진웅 on 7/19/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

import LivithDesignSystem

struct CalendarDayScheduleItemRow: View {

    // MARK: - Properties

    let item: CalendarDayScheduleItem

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: Layout.sectionSpacing) {
            timeHeader

            if item.isCancelled {
                cardLabel
                    .background(Color.livithColor(.black80))
                    .clipShape(RoundedRectangle(cornerRadius: Layout.cardCornerRadius))
                    .opacity(Layout.cancelledOpacity)
            } else {
                Button(action: {}) {
                    cardLabel
                }
                .buttonStyle(CalendarDayScheduleItemButtonStyle())
            }
        }
    }
}

// MARK: - UIComponents

private extension CalendarDayScheduleItemRow {
    var timeHeader: some View {
        HStack(spacing: Layout.timeBarSpacing) {
            RoundedRectangle(cornerRadius: 1)
                .fill(timeBarColor)
                .frame(width: Layout.timeBarWidth, height: Layout.timeBarHeight)

            Text(item.timeLabel)
                .notosans(.body4Medium)
                .foregroundStyle(Color.livithColor(.black5))
        }
    }

    var cardLabel: some View {
        HStack(alignment: .center, spacing: Layout.cardSpacing) {
            VStack(alignment: .leading, spacing: Layout.cardInnerSpacing) {
                kindChip

                Text(item.title)
                    .notosans(.body2Semibold)
                    .foregroundStyle(Color.livithColor(.white100))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                Text(item.subtitle)
                    .notosans(.body4Regular)
                    .foregroundStyle(Color.livithColor(.black50))
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if !item.isCancelled {
                Image.livithIcon(.rightLineDefault)
                    .resizable()
                    .scaledToFit()
                    .frame(width: Layout.chevronSize, height: Layout.chevronSize)
            }
        }
        .padding(Layout.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    var kindChip: some View {
        Text(kindTitle)
            .notosans(.caption1Bold)
            .foregroundStyle(Color.livithColor(.black50))
            .padding(.horizontal, Layout.chipHorizontalPadding)
            .padding(.vertical, Layout.chipVerticalPadding)
            .background(Color.livithColor(.black90))
            .clipShape(Capsule())
    }

    var kindTitle: String {
        switch item.kind {
        case .ticketing: return "예매일"
        case .performance: return "공연일"
        }
    }

    var timeBarColor: Color {
        if item.isCancelled {
            return Color.livithColor(.black50)
        }
        switch item.kind {
        case .ticketing: return Color.livithColor(.translation)
        case .performance: return Color.livithColor(.original)
        }
    }
}

// MARK: - ButtonStyle

private struct CalendarDayScheduleItemButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(backgroundColor(isPressed: configuration.isPressed))
            .clipShape(RoundedRectangle(cornerRadius: Layout.cardCornerRadius))
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }

    private func backgroundColor(isPressed: Bool) -> Color {
        isPressed
            ? Color.livithColor(.black100)
            : Color.livithColor(.black80)
    }

    private enum Layout {
        static let cardCornerRadius: CGFloat = 8
    }
}

// MARK: - Layout

private extension CalendarDayScheduleItemRow {
    enum Layout {
        static let sectionSpacing: CGFloat = 10
        static let timeBarSpacing: CGFloat = 6
        static let timeBarWidth: CGFloat = 4
        static let timeBarHeight: CGFloat = 12
        static let cardSpacing: CGFloat = 16
        static let cardInnerSpacing: CGFloat = 6
        static let cardPadding: CGFloat = 12
        static let cardCornerRadius: CGFloat = 8
        static let chipHorizontalPadding: CGFloat = 10
        static let chipVerticalPadding: CGFloat = 4
        static let chevronSize: CGFloat = 24
        static let cancelledOpacity: CGFloat = 0.3
    }
}
