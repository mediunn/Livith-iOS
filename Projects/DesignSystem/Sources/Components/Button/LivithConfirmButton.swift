//
//  LivithConfirmButton.swift
//  LivithDesignSystem
//
//  Created by Youjin Lee on 1/12/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

// MARK: - Variant

public enum LivithConfirmButtonVariant {
    /// 검정 배경, 텍스트 색상만 변경 (중복확인 스타일)
    case dark
    /// 활성화시 노란색 배경 (등록 스타일)
    case primary

    var enabledBackground: Color {
        switch self {
        case .dark:
            return .livithColor(.black80)
        case .primary:
            return .livithColor(.yellow30)
        }
    }

    var pressedBackground: Color {
        switch self {
        case .dark:
            return .livithColor(.black100)
        case .primary:
            return .livithColor(.yellow60)
        }
    }

    var disabledBackground: Color {
        return .livithColor(.black80)
    }

    var enabledForeground: Color {
        switch self {
        case .dark:
            return .livithColor(.black5)
        case .primary:
            return .livithColor(.black100)
        }
    }

    var disabledForeground: Color {
        return .livithColor(.black50)
    }
}

// MARK: - Size

public enum LivithConfirmButtonSize {
    /// 기본 높이 52
    case large
    /// 작은 높이 41
    case small

    var height: CGFloat {
        switch self {
        case .large: return 52
        case .small: return 41
        }
    }
}

// MARK: - LivithConfirmButton

public struct LivithConfirmButton: View {

    // MARK: - Property

    private let title: String
    private let variant: LivithConfirmButtonVariant
    private let size: LivithConfirmButtonSize
    private let action: () -> Void

    @Environment(\.isEnabled) private var isEnabled

    // MARK: - Lifecycle

    public init(
        _ title: String,
        variant: LivithConfirmButtonVariant = .dark,
        size: LivithConfirmButtonSize = .large,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.variant = variant
        self.size = size
        self.action = action
    }

    // MARK: - Body

    public var body: some View {
        Button(action: action) {
            Text(title)
                .notosans(.body3Medium)
                .padding(.horizontal, horizontalPadding)
                .frame(height: size.height)
        }
        .buttonStyle(
            LivithConfirmButtonStyle(
                variant: variant,
                cornerRadius: cornerRadius
            )
        )
    }
}

// MARK: - Styling

private extension LivithConfirmButton {
    var cornerRadius: CGFloat {
        switch variant {
        case .dark: return 12
        case .primary: return 8
        }
    }

    var horizontalPadding: CGFloat {
        switch variant {
        case .dark: return 16
        case .primary: return 24
        }
    }
}

// MARK: - Button Style

private struct LivithConfirmButtonStyle: ButtonStyle {
    let variant: LivithConfirmButtonVariant
    let cornerRadius: CGFloat

    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(foregroundColor)
            .background(backgroundColor(isPressed: configuration.isPressed))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }

    private var foregroundColor: Color {
        isEnabled ? variant.enabledForeground : variant.disabledForeground
    }

    private func backgroundColor(isPressed: Bool) -> Color {
        if !isEnabled {
            return variant.disabledBackground
        }
        return isPressed ? variant.pressedBackground : variant.enabledBackground
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        Text("Dark Variant (Large - 52)")
            .foregroundStyle(.white)

        HStack(spacing: 12) {
            LivithConfirmButton("중복확인", variant: .dark) {}
                .disabled(true)

            LivithConfirmButton("중복확인", variant: .dark) {}
        }

        Divider()

        Text("Dark Variant (Small - 41)")
            .foregroundStyle(.white)

        HStack(spacing: 12) {
            LivithConfirmButton("중복확인", variant: .dark, size: .small) {}
                .disabled(true)

            LivithConfirmButton("중복확인", variant: .dark, size: .small) {}
        }

        Divider()

        Text("Primary Variant (Large - 52)")
            .foregroundStyle(.white)

        HStack(spacing: 12) {
            LivithConfirmButton("등록", variant: .primary) {}
                .disabled(true)

            LivithConfirmButton("등록", variant: .primary) {}
        }

        Divider()

        Text("Primary Variant (Small - 41)")
            .foregroundStyle(.white)

        HStack(spacing: 12) {
            LivithConfirmButton("등록", variant: .primary, size: .small) {}
                .disabled(true)

            LivithConfirmButton("등록", variant: .primary, size: .small) {}
        }
    }
    .padding()
    .background(Color.livithColor(.black100))
}
