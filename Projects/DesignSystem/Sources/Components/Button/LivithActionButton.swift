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
    /// 플러스 아이콘 + 텍스트 (관심 콘서트 설정하기)
    case plus
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
                if type == .plus {
                    iconView
                }

                Text(title)
                    .notosans(.caption1Semibold)
                    .foregroundStyle(Color.livithColor(.white100))

                if type == .chevron {
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
            .frame(width: 20, height: 20)
    }
}

// MARK: - Styling

private extension LivithActionButton {
    var iconType: Image.LivithIcon {
        switch type {
        case .chevron: return .rightLineDefault
        case .plus: return .plusLineSmall
        }
    }

    var spacing: CGFloat {
        switch type {
        case .chevron: return 4
        case .plus: return 2
        }
    }

    var verticalPadding: CGFloat {
        switch type {
        case .chevron: return 8
        case .plus: return 10
        }
    }

    var horizontalPadding: CGFloat {
        switch type {
        case .chevron: return 12
        case .plus: return 10
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
                color: .livithColor(.white100).opacity(0.3),
                radius: 6
            )
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        LivithActionButton("더 많은 정보 확인하기", type: .chevron) {}

        LivithActionButton("관심 콘서트 설정하기", type: .plus) {}
    }
    .padding()
    .background(Color.livithColor(.black80))
}
