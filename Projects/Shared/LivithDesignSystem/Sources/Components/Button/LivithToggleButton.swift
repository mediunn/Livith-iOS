//
//  LivithToggleButton.swift
//  LivithDesignSystem
//
//  Created by Youjin Lee on 1/12/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

// MARK: - Style

public enum LivithToggleButtonStyle {
    /// 원어 - 보라색 배경
    case original
    /// 발음 - 흰색 배경
    case pronunciation
    /// 해석 - 분홍색 배경
    case translation
    /// 응원법 - 노란색 배경
    case fanchant

    var activeBackgroundColor: Color {
        switch self {
        case .original: return .livithColor(.original)
        case .pronunciation: return .livithColor(.white100)
        case .translation: return .livithColor(.translation)
        case .fanchant: return .livithColor(.yellow30)
        }
    }

    var activeTextColor: Color {
        .livithColor(.black100)
    }
}

// MARK: - LivithToggleButton

public struct LivithToggleButton: View {

    // MARK: - Property

    private let title: String
    private let isOn: Bool
    private let style: LivithToggleButtonStyle
    private let action: () -> Void

    // MARK: - Lifecycle

    public init(
        _ title: String,
        isOn: Bool,
        style: LivithToggleButtonStyle,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isOn = isOn
        self.style = style
        self.action = action
    }

    // MARK: - Body

    public var body: some View {
        Button(action: action) {
            Text("\(title) \(isOn ? "ON" : "OFF")")
                .notosans(.body4Semibold)
                .foregroundStyle(textColor)
                .frame(width: 72)
                .padding(.vertical, 5)
                .background(backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 50)
                        .stroke(Color.livithColor(.black80), lineWidth: isOn ? 0 : 1)
                )
        }
    }
}

// MARK: - Styling

private extension LivithToggleButton {
    var textColor: Color {
        isOn ? style.activeTextColor : .livithColor(.black50)
    }

    var backgroundColor: Color {
        isOn ? style.activeBackgroundColor : .clear
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 16) {
        HStack(spacing: 8) {
            LivithToggleButton("원어", isOn: true, style: .original) {}
            LivithToggleButton("원어", isOn: false, style: .original) {}
        }

        HStack(spacing: 8) {
            LivithToggleButton("발음", isOn: true, style: .pronunciation) {}
            LivithToggleButton("발음", isOn: false, style: .pronunciation) {}
        }

        HStack(spacing: 8) {
            LivithToggleButton("해석", isOn: true, style: .translation) {}
            LivithToggleButton("해석", isOn: false, style: .translation) {}
        }

        HStack(spacing: 8) {
            LivithToggleButton("응원법", isOn: true, style: .fanchant) {}
            LivithToggleButton("응원법", isOn: false, style: .fanchant) {}
        }
    }
    .padding()
    .background(Color.livithColor(.black100))
}
