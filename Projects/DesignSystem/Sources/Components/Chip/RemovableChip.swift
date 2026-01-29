//
//  RemovableChip.swift
//  LivithDesignSystem
//
//  Created by 김진웅 on 1/29/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

public struct RemovableChip: View {

    // MARK: - Constants

    private enum Constants {
        static let contentSpacing: CGFloat = 4
        static let iconSize: CGFloat = 20
        static let horizontalPadding: CGFloat = 8
        static let verticalPadding: CGFloat = 4
        static let cornerRadius: CGFloat = 24
    }

    // MARK: - Property

    private let text: String
    private let onRemove: () -> Void

    // MARK: - Lifecycle

    public init(
        _ text: String,
        onRemove: @escaping () -> Void
    ) {
        self.text = text
        self.onRemove = onRemove
    }

    // MARK: - Body

    public var body: some View {
        HStack(spacing: Constants.contentSpacing) {
            Text(text)
                .notosans(.body4Semibold)
                .foregroundStyle(Color.livithColor(.black100))
                .lineLimit(1)

            Button(action: onRemove) {
                Image.livithIcon(.closeLineSmall)
                    .renderingMode(.template)
                    .frame(width: Constants.iconSize, height: Constants.iconSize)
                    .tint(Color.livithColor(.black100))
            }
            .buttonStyle(.plain)
        }
        .padding(.leading, Constants.horizontalPadding)
        .padding(.trailing, Constants.horizontalPadding)
        .padding(.vertical, Constants.verticalPadding)
        .background(Color.livithColor(.yellow30))
        .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
    }
}

// MARK: - Preview

#Preview("Removable Chip") {
    VStack(spacing: 8) {
        RemovableChip("J-POP") {
            print("Remove J-POP")
        }
        
        HStack(spacing: 8) {
            RemovableChip("락/메탈") {}
            RemovableChip("클래식/재즈") {}
        }
    }
    .padding()
    .background(Color.livithColor(.black100))
}
