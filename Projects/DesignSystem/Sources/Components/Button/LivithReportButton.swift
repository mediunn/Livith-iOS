//
//  LivithReportButton.swift
//  LivithDesignSystem
//
//  Created by Youjin Lee on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

// MARK: - Variant

public enum LivithReportButtonVariant {
    /// 삭제, 신고 등 일반 버튼
    case `default`
    /// 정보제보 버튼
    case info

    var pressedBackground: Color {
        switch self {
        case .default:
            return .livithColor(.black80)
        case .info:
            return .livithColor(.black100)
        }
    }
}

// MARK: - LivithReportButton

public struct LivithReportButton: View {

    // MARK: - Property

    private let title: String
    private let variant: LivithReportButtonVariant
    private let action: () -> Void

    // MARK: - Initializer

    public init(
        _ title: String,
        variant: LivithReportButtonVariant = .default,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.variant = variant
        self.action = action
    }

    // MARK: - Body

    public var body: some View {
        Button(action: action) {
            Text(title)
                .notosans(.caption1Semibold)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
        }
        .buttonStyle(LivithReportButtonStyle(variant: variant))
    }
}

// MARK: - Button Style

private struct LivithReportButtonStyle: ButtonStyle {
    let variant: LivithReportButtonVariant

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(
                configuration.isPressed
                    ? Color.livithColor(.black50)
                    : Color.livithColor(.black80)
            )
            .background(
                configuration.isPressed
                    ? variant.pressedBackground
                    : Color.livithColor(.black100)
            )
            .clipShape(Capsule())
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.livithColor(.black90)
            .ignoresSafeArea()

        VStack(spacing: 20) {
            HStack(spacing: 8) {
                LivithReportButton("삭제") {}
                LivithReportButton("신고") {}
                LivithReportButton("정보 제보", variant: .info) {}
            }
        }
    }
}
