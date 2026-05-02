//
//  LivithActionButton.swift
//  LivithDesignSystem
//
//  Created by Youjin Lee on 1/12/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

// MARK: - Type

public enum LivithActionButtonType {
    /// 텍스트 + 오른쪽 화살표 (더 많은 정보 확인하기)
    case chevron
    /// 종 아이콘 + 텍스트 (소식 받기 / 소식 받는중)
    case notice(isActive: Bool)
}

// MARK: - LivithActionButton

public struct LivithActionButton: View {

    // MARK: - Property

    private let title: String
    private let type: LivithActionButtonType
    private let action: () -> Void

    // MARK: - Lifecycle

    public init(
        _ title: String,
        type: LivithActionButtonType,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.type = type
        self.action = action
    }

    // MARK: - Body

    public var body: some View {
        Button(action: action) {
            HStack(spacing: spacing) {
                if isLeadingIcon {
                    iconView
                }

                Text(title)
                    .notosans(.caption1Semibold)
                    .foregroundStyle(textColor)

                if isTrailingIcon {
                    iconView
                }
            }
            .padding(.vertical, verticalPadding)
            .padding(.horizontal, horizontalPadding)
        }
        .buttonStyle(LivithActionButtonStyle())
    }
}

// MARK: - Subviews

private extension LivithActionButton {
    var iconView: some View {
        Image.livithIcon(iconType)
            .resizable()
            .renderingMode(.template)
            .foregroundStyle(iconColor)
            .frame(width: 24, height: 24)
    }
}

// MARK: - Styling

private extension LivithActionButton {
    var iconType: Image.LivithIcon {
        switch type {
        case .chevron: return .rightLineDefault
        case .notice: return .noticeVariant2
        }
    }

    var isLeadingIcon: Bool {
        switch type {
        case .chevron: return false
        case .notice: return true
        }
    }

    var isTrailingIcon: Bool {
        switch type {
        case .chevron: return true
        case .notice: return false
        }
    }

    var textColor: Color {
        switch type {
        case .chevron:
            return Color.livithColor(.white100)
        case .notice(let isActive):
            return Color.livithColor(isActive ? .white100 : .black50)
        }
    }

    var iconColor: Color {
        switch type {
        case .chevron:
            return Color.livithColor(.white100)
        case .notice(let isActive):
            return Color.livithColor(isActive ? .yellow30 : .black50)
        }
    }

    var spacing: CGFloat {
        switch type {
        case .chevron: return 4
        case .notice: return 4
        }
    }

    var verticalPadding: CGFloat {
        switch type {
        case .chevron: return 8
        case .notice: return 8
        }
    }

    var horizontalPadding: CGFloat {
        switch type {
        case .chevron: return 12
        case .notice: return 12
        }
    }
}

// MARK: - Style

private struct LivithActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                configuration.isPressed
                ? Color.livithColor(.black80)
                : Color.livithColor(.black100)
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .shadow(
                color: .livithColor(.black100).opacity(0.3),
                radius: 6
            )
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        LivithActionButton("더 많은 정보 확인하기", type: .chevron) {}

        LivithActionButton("소식 받기", type: .notice(isActive: false)) {}

        LivithActionButton("소식 받는중", type: .notice(isActive: true)) {}
    }
    .padding()
    .background(Color.livithColor(.black80))
}
