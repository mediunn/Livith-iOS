//
//  LivithIconBadge.swift
//  LivithDesignSystem
//
//  Created by Youjin Lee on 1/6/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

// MARK: - LivithIconBadge

public struct LivithIconBadge: View {

    // MARK: - Property

    private let icon: Image.LivithIcon
    private let text: String
    private let backgroundColor: Color
    private let textColor: Color

    // MARK: - Lifecycle

    public init(
        icon: Image.LivithIcon,
        text: String,
        backgroundColor: Color = .livithColor(.translation),
        textColor: Color = .livithColor(.black100)
    ) {
        self.icon = icon
        self.text = text
        self.backgroundColor = backgroundColor
        self.textColor = textColor
    }

    // MARK: - Body

    public var body: some View {
        HStack(spacing: 0) {
            Image.livithIcon(icon)
                .resizable()
                .frame(width: 24, height: 24)

            Text(text)
                .notosans(.caption2Semibold)
                .foregroundStyle(textColor)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 2)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

// MARK: - Convenience

public extension LivithIconBadge {
    /// 인기 순위 배지 (분홍색 배경)
    static func popular(_ text: String) -> LivithIconBadge {
        LivithIconBadge(
            icon: .badge,
            text: text,
            backgroundColor: .livithColor(.translation),
            textColor: .livithColor(.black100)
        )
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 12) {
        LivithIconBadge.popular("많이 찾는 콘서트 1위")
        LivithIconBadge(icon: .badge, text: "HOT")
    }
    .padding()
    .background(Color.livithColor(.black100))
}
