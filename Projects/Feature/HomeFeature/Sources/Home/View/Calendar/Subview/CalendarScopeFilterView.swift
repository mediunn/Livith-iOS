//
//  CalendarScopeFilterView.swift
//  HomeFeature
//
//  Created by 김진웅 on 7/19/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

import LivithDesignSystem

struct CalendarScopeFilterView: View {

    // MARK: - Properties

    let selectedScope: CalendarConcertScope
    let onAllConcertsTap: () -> Void
    let onMyConcertsTap: () -> Void

    // MARK: - Body

    var body: some View {
        HStack(spacing: Layout.overlapSpacing) {
            scopeChip(
                title: "전체 공연",
                isSelected: selectedScope == .all,
                isLeading: true,
                action: onAllConcertsTap
            )

            scopeChip(
                title: "내 공연",
                isSelected: selectedScope == .my,
                isLeading: false,
                action: onMyConcertsTap
            )
        }
    }
}

// MARK: - UIComponents

private extension CalendarScopeFilterView {
    func scopeChip(
        title: String,
        isSelected: Bool,
        isLeading: Bool,
        action: @escaping () -> Void
    ) -> some View {
        let padding = chipHorizontalPadding(isSelected: isSelected, isLeading: isLeading)

        return Button(action: action) {
            let label = Text(title)
                .notosans(.caption1Bold)
                .foregroundStyle(isSelected ? Color.livithColor(.black90) : Color.livithColor(.black50))
                .padding(.leading, padding.leading)
                .padding(.trailing, padding.trailing)
                .frame(height: Layout.chipHeight)
                .background(isSelected ? Color.livithColor(.black30) : Color.livithColor(.black90))

            if isSelected {
                label.clipShape(Capsule())
            } else if isLeading {
                label.clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: Layout.cornerRadius,
                        bottomLeadingRadius: Layout.cornerRadius,
                        bottomTrailingRadius: .zero,
                        topTrailingRadius: .zero
                    )
                )
            } else {
                label.clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: .zero,
                        bottomLeadingRadius: .zero,
                        bottomTrailingRadius: Layout.cornerRadius,
                        topTrailingRadius: Layout.cornerRadius
                    )
                )
            }
        }
        .buttonStyle(.plain)
        .zIndex(isSelected ? 2 : 1)
    }

    func chipHorizontalPadding(
        isSelected: Bool,
        isLeading: Bool
    ) -> (leading: CGFloat, trailing: CGFloat) {
        if isSelected {
            return (Layout.horizontalPadding, Layout.horizontalPadding)
        }

        if isLeading {
            return (Layout.horizontalPadding, Layout.overlapPadding)
        }

        return (Layout.overlapPadding, Layout.horizontalPadding)
    }
}

// MARK: - Layout

private extension CalendarScopeFilterView {
    enum Layout {
        static let chipHeight: CGFloat = 28
        static let horizontalPadding: CGFloat = 12
        static let overlapPadding: CGFloat = 20
        static let cornerRadius: CGFloat = 24
        static let overlapSpacing: CGFloat = -12
    }
}
