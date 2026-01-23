//
//  LivithTextButton.swift
//  LivithDesignSystem
//
//  Created by Youjin Lee on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

// MARK: - LivithTextButton

public struct LivithTextButton: View {

    // MARK: - Property

    private let title: String
    private let action: () -> Void

    // MARK: - Initializer

    public init(
        _ title: String,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.action = action
    }

    // MARK: - Body

    public var body: some View {
        Button(action: action) {
            Text(title)
                .notosans(.body4Semibold)
                .foregroundStyle(Color.livithColor(.white100))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
        }
        .buttonStyle(LivithTextButtonStyle())
    }
}

// MARK: - Button Style

private struct LivithTextButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                configuration.isPressed
                    ? Color.livithColor(.black100)
                    : Color.livithColor(.black80)
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

        VStack(spacing: 16) {
            LivithTextButton("수정하기") {}
            LivithTextButton("건너뛰기") {}
            LivithTextButton("변경하기") {}
            LivithTextButton("설정하기") {}
        }
    }
}
