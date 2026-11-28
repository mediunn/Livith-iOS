//
//  LivithChip.swift
//  LivithDesignSystem
//
//  Created by Youjin Lee on 1/12/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

// MARK: - Style

public enum LivithChipStyle {
    /// D-day 기본 (black90 bg, black30 text)
    case status
    /// 선택됨 (yellow30 bg, black100 text)
    case selected
    /// 태그 (black80 bg, black30 text)
    case tag
    /// 카드/카테고리 (black100 bg, black50 text)
    case dark
    /// 아웃라인 (clear bg + border, black50 text)
    case outline

    var backgroundColor: Color {
        switch self {
        case .status: return .livithColor(.black90)
        case .selected: return .livithColor(.yellow30)
        case .tag: return .livithColor(.black80)
        case .dark: return .livithColor(.black100)
        case .outline: return .clear
        }
    }

    var textColor: Color {
        switch self {
        case .status, .tag: return .livithColor(.black30)
        case .selected: return .livithColor(.black100)
        case .dark, .outline: return .livithColor(.black50)
        }
    }

    var hasBorder: Bool {
        self == .outline
    }

    var cornerRadius: CGFloat {
        switch self {
        case .tag: return 16
        default: return 24
        }
    }

    var horizontalPadding: CGFloat {
        switch self {
        case .dark: return 9
        default: return 12
        }
    }

    var verticalPadding: CGFloat {
        switch self {
        case .status, .selected: return 7
        case .tag: return 8
        case .dark, .outline: return 4
        }
    }
}

// MARK: - LivithChip

public struct LivithChip: View {

    // MARK: - Property

    private let text: String
    private let style: LivithChipStyle

    // MARK: - Lifecycle

    public init(_ text: String, style: LivithChipStyle = .status) {
        self.text = text
        self.style = style
    }

    // MARK: - Body

    public var body: some View {
        Text(text)
            .notosans(.caption1Bold)
            .foregroundStyle(style.textColor)
            .padding(.horizontal, style.horizontalPadding)
            .frame(height: 30)
            .background(style.backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: style.cornerRadius))
            .overlay {
                if style.hasBorder {
                    RoundedRectangle(cornerRadius: style.cornerRadius)
                        .strokeBorder(Color.livithColor(.black50), lineWidth: 1)
                }
            }
    }
}

// MARK: - Convenience Initializers

public extension LivithChip {
    /// D-day 칩 (ConcertStatusChip 대체)
    static func dDay(_ text: String, remainDays: Int, isSelected: Bool = false) -> LivithChip {
        let displayText = remainDays <= 0 ? text : "\(text)\(remainDays)"
        return LivithChip(displayText, style: isSelected ? .selected : .status)
    }
}

// MARK: - LivithChipButton

public struct LivithChipButton: View {

    // MARK: - Property

    private let text: String
    private let style: LivithChipStyle
    private let action: () -> Void

    // MARK: - Lifecycle

    public init(
        _ text: String,
        style: LivithChipStyle = .status,
        action: @escaping () -> Void
    ) {
        self.text = text
        self.style = style
        self.action = action
    }

    // MARK: - Body

    public var body: some View {
        Button(action: action) {
            LivithChip(text, style: style)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview("Chip Styles") {
    VStack(spacing: 16) {
        HStack(spacing: 8) {
            LivithChip("D-3", style: .status)
            LivithChip("D-3", style: .selected)
        }

        HStack(spacing: 8) {
            LivithChip("J-POP", style: .tag)
            LivithChip("공식", style: .tag)
        }

        HStack(spacing: 8) {
            LivithChip("라이빗 팀블로그", style: .dark)
            LivithChip("일본 내한 가수", style: .dark)
        }

        HStack(spacing: 8) {
            LivithChip("정보 제보", style: .outline)
            LivithChip("진행중", style: .outline)
        }
    }
    .padding()
    .background(Color.livithColor(.black100))
}

#Preview("D-Day Convenience") {
    VStack(spacing: 8) {
        LivithChip.dDay("D-", remainDays: 3)
        LivithChip.dDay("D-", remainDays: 3, isSelected: true)
        LivithChip.dDay("종료", remainDays: 0)
    }
    .padding()
    .background(Color.livithColor(.black100))
}

#Preview("Chip Button") {
    VStack(spacing: 8) {
        LivithChipButton("진행중", style: .outline) {}
        LivithChipButton("진행중", style: .selected) {}
    }
    .padding()
    .background(Color.livithColor(.black100))
}
