//
//  LivithOptionButton.swift
//  LivithDesignSystem
//
//  Created by Youjin Lee on 1/12/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

// MARK: - LivithOptionButton

public struct LivithOptionButton: View {

    // MARK: - Property

    private let title: String
    private let isSelected: Bool
    private let action: () -> Void

    // MARK: - Lifecycle

    public init(
        _ title: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isSelected = isSelected
        self.action = action
    }

    // MARK: - Body

    public var body: some View {
        Button(action: action) {
            Text(title)
                .frame(width: 70)
                .padding(.vertical, 3)
                .notosans(.body4Semibold)
                .foregroundStyle(textColor)
                .background {
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundStyle(backgroundColor)
                }
        }
    }
}

// MARK: - Styling

private extension LivithOptionButton {
    var textColor: Color {
        isSelected ? .livithColor(.black100) : .livithColor(.white100)
    }

    var backgroundColor: Color {
        isSelected ? .livithColor(.yellow30) : .clear
    }
}

// MARK: - Preview

#Preview {
    HStack(spacing: 0) {
        LivithOptionButton("인기순", isSelected: true) {}
        LivithOptionButton("최신순", isSelected: false) {}
    }
    .padding(4)
    .background(Color.livithColor(.black80))
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .padding()
    .background(Color.livithColor(.black100))
}
