//
//  CalendarDayScheduleItemRow.swift
//  HomeFeature
//
//  Created by 김진웅 on 7/19/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

import Domain
import LivithDesignSystem

struct CalendarDayScheduleItemRow: View {

    // MARK: - Properties

    let event: CalendarDayEvent
    let onTap: () -> Void

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: Layout.sectionSpacing) {
            timeHeader

            if event.isCancelled {
                cardLabel
                    .background(Color.livithColor(.black80))
                    .clipShape(RoundedRectangle(cornerRadius: Layout.cardCornerRadius))
                    .opacity(Layout.cancelledOpacity)
            } else {
                Button(action: onTap) {
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

            Text(event.timeLabel)
                .notosans(.body4Medium)
                .foregroundStyle(Color.livithColor(.black5))
        }
    }

    var cardLabel: some View {
        HStack(alignment: .center, spacing: Layout.cardSpacing) {
            VStack(alignment: .leading, spacing: Layout.cardInnerSpacing) {
                kindChip

                Text(event.displayTitle)
                    .notosans(.body2Semibold)
                    .foregroundStyle(Color.livithColor(.white100))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                Text(event.detailText)
                    .notosans(.body4Regular)
                    .foregroundStyle(Color.livithColor(.black50))
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if !event.isCancelled {
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
        Text(event.kindTitle)
            .notosans(.caption1Bold)
            .foregroundStyle(Color.livithColor(.black50))
            .padding(.horizontal, Layout.chipHorizontalPadding)
            .padding(.vertical, Layout.chipVerticalPadding)
            .background(Color.livithColor(.black90))
            .clipShape(Capsule())
    }

    var timeBarColor: Color {
        if event.isCancelled {
            return Color.livithColor(.black50)
        }
        switch event.scheduleKind {
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
