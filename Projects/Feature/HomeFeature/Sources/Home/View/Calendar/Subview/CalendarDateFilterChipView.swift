//
//  CalendarDateFilterChipView.swift
//  HomeFeature
//
//  Created by 김진웅 on 7/19/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

import LivithDesignSystem

struct CalendarDateFilterChipView: View {

    // MARK: - Properties

    let kind: Kind
    let isSelected: Bool
    let onTap: () -> Void

    // MARK: - Body

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Layout.dotSpacing) {
                Circle()
                    .fill(kind.dotColor)
                    .frame(width: Layout.dotSize, height: Layout.dotSize)

                Text(kind.title)
                    .notosans(.caption1Bold)
                    .foregroundStyle(Color.livithColor(isSelected ? .black30 : .black50))
            }
            .padding(.horizontal, Layout.horizontalPadding)
            .frame(height: Layout.chipHeight)
            .background(Color.livithColor(.black90))
            .clipShape(Capsule())
            .overlay {
                if isSelected {
                    Capsule()
                        .strokeBorder(Color.livithColor(.black30), lineWidth: 1)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Kind

extension CalendarDateFilterChipView {
    enum Kind {
        case ticketing
        case performance

        var title: String {
            switch self {
            case .ticketing: return "예매일"
            case .performance: return "공연일"
            }
        }

        var dotColor: Color {
            switch self {
            case .ticketing: return Color.livithColor(.translation)
            case .performance: return Color.livithColor(.original)
            }
        }
    }
}

// MARK: - Layout

private extension CalendarDateFilterChipView {
    enum Layout {
        static let chipHeight: CGFloat = 28
        static let dotSize: CGFloat = 4
        static let dotSpacing: CGFloat = 4
        static let horizontalPadding: CGFloat = 13
    }
}
