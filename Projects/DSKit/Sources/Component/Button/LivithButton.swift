//
//  LivithButton.swift
//  DSKit
//
//  Created by Youjin Lee on 1/6/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

// MARK: - Button Style

public enum LivithButtonVariant {
    case primary
    case pink
    case secondary
    case danger
    case dark

    var enabledBackground: Color {
        switch self {
        case .primary:
            return .livithColor(.yellow30)
        case .pink:
            return .livithColor(.translation)
        case .secondary:
            return .livithColor(.black50)
        case .danger:
            return .livithColor(.black5)
        case .dark:
            return .livithColor(.black80)
        }
    }

    var pressedBackground: Color {
        switch self {
        case .primary:
            return .livithColor(.yellow60)
        case .pink:
            return .livithColor(.translation).opacity(0.8)
        case .secondary, .dark:
            return .livithColor(.black80)
        case .danger:
            return .livithColor(.black5).opacity(0.8)
        }
    }

    var disabledBackground: Color {
        switch self {
        case .primary, .pink:
            return .livithColor(.black50)
        case .secondary, .dark:
            return .livithColor(.black80)
        case .danger:
            return .livithColor(.black5)
        }
    }

    var enabledForeground: Color {
        switch self {
        case .primary, .pink:
            return .livithColor(.black100)
        case .secondary:
            return .livithColor(.white100)
        case .danger:
            return .livithColor(.caution100)
        case .dark:
            return .livithColor(.white100)
        }
    }

    var disabledForeground: Color {
        switch self {
        case .primary, .pink:
            return .livithColor(.black30)
        case .secondary, .dark:
            return .livithColor(.black50)
        case .danger:
            return .livithColor(.black50)
        }
    }
}

// MARK: - Button Size

public enum LivithButtonSize {
    case medium
    case large

    var height: CGFloat {
        switch self {
        case .medium:
            return 52
        case .large:
            return 56
        }
    }

    var font: Font.Notosans {
        switch self {
        case .medium:
            return .body3Semibold
        case .large:
            return .body2Medium
        }
    }

    var cornerRadius: CGFloat {
        switch self {
        case .medium:
            return 6
        case .large:
            return 8
        }
    }
}

// MARK: - LivithButton

public struct LivithButton: View {

    // MARK: - Property

    private let title: String
    private let variant: LivithButtonVariant
    private let size: LivithButtonSize
    private let isFullWidth: Bool
    private let isLoading: Bool
    private let cornerRadius: CGFloat?
    private let action: () -> Void

    @Environment(\.isEnabled) private var isEnabled

    private var resolvedCornerRadius: CGFloat {
        cornerRadius ?? size.cornerRadius
    }

    // MARK: - Initializer

    public init(
        _ title: String,
        variant: LivithButtonVariant = .primary,
        size: LivithButtonSize = .medium,
        isFullWidth: Bool = true,
        isLoading: Bool = false,
        cornerRadius: CGFloat? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.variant = variant
        self.size = size
        self.isFullWidth = isFullWidth
        self.isLoading = isLoading
        self.cornerRadius = cornerRadius
        self.action = action
    }

    // MARK: - Body

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(title)
                    .notosans(size.font)
                    .foregroundStyle(isEnabled ? variant.enabledForeground : variant.disabledForeground)

                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: variant.enabledForeground))
                }
            }
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .frame(height: size.height)
        }
        .buttonStyle(LivithButtonStyle(variant: variant, cornerRadius: resolvedCornerRadius))
    }
}

// MARK: - Button Style

private struct LivithButtonStyle: ButtonStyle {
    let variant: LivithButtonVariant
    let cornerRadius: CGFloat

    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(backgroundColor(isPressed: configuration.isPressed))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }

    private func backgroundColor(isPressed: Bool) -> Color {
        if !isEnabled {
            return variant.disabledBackground
        }
        return isPressed ? variant.pressedBackground : variant.enabledBackground
    }
}

// MARK: - Preview

#Preview("Primary Button") {
    ZStack {
        Color.livithColor(.black100)
            .ignoresSafeArea()

        VStack(spacing: 16) {
            LivithButton("설정하기", variant: .primary) {
                print("Primary tapped")
            }

            LivithButton("비활성화 버튼", variant: .primary) {
                print("Disabled tapped")
            }
            .disabled(true)
        }
        .padding(.horizontal, 16)
    }
}

#Preview("Pink Button") {
    ZStack {
        Color.livithColor(.black100)
            .ignoresSafeArea()

        VStack(spacing: 16) {
            LivithButton("탈퇴할래요", variant: .pink) {
                print("Pink tapped")
            }

            LivithButton("비활성화 버튼", variant: .pink) {
                print("Disabled tapped")
            }
            .disabled(true)
        }
        .padding(.horizontal, 16)
    }
}

#Preview("Secondary Button") {
    ZStack {
        Color.livithColor(.black100)
            .ignoresSafeArea()

        VStack(spacing: 16) {
            LivithButton("취소할래요", variant: .secondary) {
                print("Secondary tapped")
            }

            LivithButton("초기화", variant: .secondary) {
                print("Reset tapped")
            }
            .disabled(true)
        }
        .padding(.horizontal, 16)
    }
}

#Preview("Large Buttons") {
    ZStack {
        Color.livithColor(.black100)
            .ignoresSafeArea()

        VStack(spacing: 16) {
            LivithButton("가입하기", variant: .primary, size: .large) {
                print("Large primary tapped")
            }

            LivithButton("확인했어요", variant: .pink, size: .large) {
                print("Large pink tapped")
            }
        }
        .padding(.horizontal, 16)
    }
}

#Preview("Button Pair") {
    ZStack {
        Color.livithColor(.black100)
            .ignoresSafeArea()

        HStack(spacing: 12) {
            LivithButton("취소할래요", variant: .secondary) {
                print("Cancel tapped")
            }

            LivithButton("탈퇴할래요", variant: .pink) {
                print("Confirm tapped")
            }
        }
        .padding(.horizontal, 16)
    }
}
