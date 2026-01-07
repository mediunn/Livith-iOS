//
//  LivithConfirmButton.swift
//  DSKit
//
//  Created by Youjin Lee on 1/6/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

// MARK: - Variant

public enum LivithConfirmButtonVariant {
    /// 검정 배경, 텍스트 색상만 변경 (중복확인 스타일)
    case dark
    /// 활성화시 노란색 배경 (등록 스타일)
    case primary
}

// MARK: - LivithConfirmButton

public struct LivithConfirmButton: View {

    // MARK: - Property

    private let title: String
    private let variant: LivithConfirmButtonVariant
    private let action: () -> Void

    @Environment(\.isEnabled) private var isEnabled

    // MARK: - Lifecycle

    public init(
        _ title: String,
        variant: LivithConfirmButtonVariant = .dark,
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
                .notosans(.body3Medium)
                .foregroundStyle(foregroundColor)
                .padding(.horizontal, horizontalPadding)
                .padding(.vertical, verticalPadding)
                .frame(minWidth: minWidth)
                .background(backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        }
    }
}

// MARK: - Styling

private extension LivithConfirmButton {
    var foregroundColor: Color {
        switch variant {
        case .dark:
            return isEnabled ? .livithColor(.black5) : .livithColor(.black50)
        case .primary:
            return isEnabled ? .livithColor(.black100) : .livithColor(.black50)
        }
    }

    var backgroundColor: Color {
        switch variant {
        case .dark:
            return .livithColor(.black80)
        case .primary:
            return isEnabled ? .livithColor(.yellow30) : .livithColor(.black80)
        }
    }

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

    var verticalPadding: CGFloat {
        switch variant {
        case .dark: return 16
        case .primary: return 12
        }
    }

    var minWidth: CGFloat? {
        switch variant {
        case .dark: return 80
        case .primary: return nil
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        Text("Dark Variant")
            .foregroundStyle(.white)

        HStack(spacing: 12) {
            LivithConfirmButton("중복확인", variant: .dark) {}
                .disabled(true)

            LivithConfirmButton("중복확인", variant: .dark) {}

            LivithConfirmButton("확인완료", variant: .dark) {}
        }

        Divider()

        Text("Primary Variant")
            .foregroundStyle(.white)

        HStack(spacing: 12) {
            LivithConfirmButton("등록", variant: .primary) {}
                .disabled(true)

            LivithConfirmButton("등록", variant: .primary) {}
        }
    }
    .padding()
    .background(Color.livithColor(.black100))
}
