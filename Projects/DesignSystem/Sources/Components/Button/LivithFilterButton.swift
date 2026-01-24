//
//  LivithFilterButton.swift
//  LivithDesignSystem
//
//  Created by Youjin Lee on 1/12/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

// MARK: - Style

public enum LivithFilterButtonStyle {
    case genre
    case status

    var icon: Image.LivithIcon {
        switch self {
        case .genre: return .genreLine
        case .status: return .calendarLine
        }
    }

    var defaultTitle: String {
        switch self {
        case .genre: return "전체장르"
        case .status: return "전체기간"
        }
    }
}

// MARK: - LivithFilterButton

public struct LivithFilterButton: View {

    // MARK: - Property

    private let style: LivithFilterButtonStyle
    private let selectedText: String?
    private let action: () -> Void
    private let onClear: (() -> Void)?

    private var isSelected: Bool {
        selectedText != nil
    }

    // MARK: - Lifecycle

    public init(
        style: LivithFilterButtonStyle,
        selectedText: String? = nil,
        action: @escaping () -> Void,
        onClear: (() -> Void)? = nil
    ) {
        self.style = style
        self.selectedText = selectedText
        self.action = action
        self.onClear = onClear
    }

    // MARK: - Body

    public var body: some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: 0) {
                iconView
                    .frame(width: 20, height: 20)

                titleView
                    .padding(.leading, 4)

                trailingView
                    .padding(.trailing, 8)
            }
            .padding(.leading, 6)
        }
        .frame(height: 30)
        .background(backgroundView)
    }
}

// MARK: - Subviews

private extension LivithFilterButton {
    var iconView: some View {
        Image.livithIcon(style.icon)
            .renderingMode(.template)
            .tint(isSelected ? Color.livithColor(.black100) : Color.livithColor(.black30))
            .offset(y: style == .genre ? 1 : 0)
    }

    var titleView: some View {
        Text(selectedText ?? style.defaultTitle)
            .notosans(isSelected ? .body4Semibold : .body4Medium)
            .foregroundStyle(isSelected ? Color.livithColor(.black100) : Color.livithColor(.black30))
    }

    @ViewBuilder
    var trailingView: some View {
        if isSelected {
            Button {
                onClear?()
            } label: {
                Image.livithIcon(.closeLineSmall)
                    .renderingMode(.template)
                    .tint(Color.livithColor(.black100))
            }
            .buttonStyle(.plain)
        } else {
            Image.livithIcon(.downLineSmall)
                .renderingMode(.template)
                .tint(Color.livithColor(.black30))
        }
    }

    @ViewBuilder
    var backgroundView: some View {
        if isSelected {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.livithColor(.yellow30))
        } else {
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(Color.livithColor(.black50), lineWidth: 1)
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 12) {
        HStack(spacing: 8) {
            LivithFilterButton(style: .genre, action: {})
            LivithFilterButton(style: .status, action: {})
        }

        HStack(spacing: 8) {
            LivithFilterButton(style: .genre, selectedText: "J-POP, K-POP", action: {}, onClear: {})
            LivithFilterButton(style: .status, selectedText: "진행중", action: {}, onClear: {})
        }
    }
    .padding()
    .background(Color.livithColor(.black100))
}
