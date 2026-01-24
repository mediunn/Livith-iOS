//
//  LivithLoginButton.swift
//  LivithDesignSystem
//
//  Created by Youjin Lee on 1/12/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

public enum LivithLoginProvider {
    case kakao
    case apple

    var title: String {
        switch self {
        case .kakao:
            return "카카오로 계속하기"
        case .apple:
            return "Apple로 계속하기"
        }
    }

    var icon: Image {
        switch self {
        case .kakao:
            return .livithIcon(.kakao)
        case .apple:
            return .livithIcon(.apple)
        }
    }

    var backgroundColor: Color {
        switch self {
        case .kakao:
            return Color(hex: "#fce64a")
        case .apple:
            return Color(hex: "#222831")
        }
    }

    var textColor: Color {
        switch self {
        case .kakao:
            return Color(hex: "#14171b")
        case .apple:
            return Color(hex: "#f2f4f6")
        }
    }
}

// MARK: - LivithLoginButton

public struct LivithLoginButton: View {

    // MARK: - Property

    private let provider: LivithLoginProvider
    private let action: () -> Void

    // MARK: - Initializer

    public init(
        provider: LivithLoginProvider,
        action: @escaping () -> Void
    ) {
        self.provider = provider
        self.action = action
    }

    // MARK: - Body

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 0) {
                provider.icon
                    .resizable()
                    .frame(width: 20, height: 20)
                    .padding(.leading, 20)
                    .padding(.vertical, 16)

                Spacer()

                Text(provider.title)
                    .notosans(.body3Medium)
                    .foregroundStyle(provider.textColor)

                Spacer()

                Rectangle()
                    .fill(.clear)
                    .frame(width: 40)
            }
            .frame(height: 52)
            .background(provider.backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}

// MARK: - Preview

#Preview("Kakao Login") {
    LivithLoginButton(provider: .kakao) {
        print("Kakao login tapped")
    }
    .padding(.horizontal, 16)
}

#Preview("Apple Login") {
    ZStack {
        Color.livithColor(.black100)
            .ignoresSafeArea()

        LivithLoginButton(provider: .apple) {
            print("Apple login tapped")
        }
        .padding(.horizontal, 16)
    }
}

#Preview("Both Buttons") {
    ZStack {
        Color.livithColor(.black100)
            .ignoresSafeArea()

        VStack(spacing: 12) {
            LivithLoginButton(provider: .kakao) {
                print("Kakao login tapped")
            }

            LivithLoginButton(provider: .apple) {
                print("Apple login tapped")
            }
        }
        .padding(.horizontal, 16)
    }
}
