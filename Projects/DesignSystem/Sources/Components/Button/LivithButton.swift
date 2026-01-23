//
//  LivithButton.swift
//  LivithDesignSystem
//
//  Created by Youjin Lee on 1/12/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

// MARK: - Button Style

public enum LivithButtonVariant {
    case primary
    case pink

    var enabledBackground: Color {
        switch self {
        case .primary:
            return .livithColor(.yellow30)
        case .pink:
            return .livithColor(.translation)
        }
    }

    var pressedBackground: Color {
        switch self {
        case .primary:
            return .livithColor(.yellow60)
        case .pink:
            return .livithColor(.translation).opacity(0.8)
        }
    }

    var disabledBackground: Color {
        return .livithColor(.black50)
    }

    var enabledForeground: Color {
        return .livithColor(.black100)
    }

    var disabledForeground: Color {
        return .livithColor(.black30)
    }
}

// MARK: - Button Constants

private enum LivithButtonConstants {
    static let height: CGFloat = 52
    static let font: Font.Notosans = .body3Semibold
    static let cornerRadius: CGFloat = 6
}

// MARK: - LivithButton

public struct LivithButton: View {

    // MARK: - Property

    private let title: String
    private let variant: LivithButtonVariant
    private let isFullWidth: Bool
    private let isLoading: Bool
    private let cornerRadius: CGFloat?
    private let action: () -> Void

    @Environment(\.isEnabled) private var isEnabled

    private var resolvedCornerRadius: CGFloat {
        cornerRadius ?? LivithButtonConstants.cornerRadius
    }

    // MARK: - Initializer

    public init(
        _ title: String,
        variant: LivithButtonVariant = .primary,
        isFullWidth: Bool = true,
        isLoading: Bool = false,
        cornerRadius: CGFloat? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.variant = variant
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
                    .notosans(LivithButtonConstants.font)
                    .foregroundStyle(isEnabled ? variant.enabledForeground : variant.disabledForeground)

                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: variant.enabledForeground))
                }
            }
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .frame(height: LivithButtonConstants.height)
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

#Preview("Button Pair") {
    ZStack {
        Color.livithColor(.black100)
            .ignoresSafeArea()

        HStack(spacing: 12) {
            LivithButton("설정하기", variant: .primary) {
                print("Primary tapped")
            }

            LivithButton("탈퇴할래요", variant: .pink) {
                print("Pink tapped")
            }
        }
        .padding(.horizontal, 16)
    }
}
