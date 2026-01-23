//
//  LivithCalloutView.swift
//  LivithDesignSystem
//
//  Created by Youjin Lee on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

// MARK: - LivithCalloutView

public struct LivithCalloutView: View {

    // MARK: - Property

    private let text: String
    private let highlightText: String?

    // MARK: - Initializer

    public init(
        _ text: String,
        highlight highlightText: String? = nil
    ) {
        self.text = text
        self.highlightText = highlightText
    }

    // MARK: - Body

    public var body: some View {
        ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.livithColor(.black80))
                .frame(height: 32)
                .overlay {
                    Text(attributedString)
                        .notosans(.caption1Bold)
                }

            TriangleTail()
                .fill(Color.livithColor(.black80))
                .frame(width: 12, height: 8)
                .offset(y: 8)
        }
        .frame(height: 40)
    }
}

// MARK: - Helper

private extension LivithCalloutView {
    var attributedString: AttributedString {
        var attributedString = AttributedString(text)
        attributedString.foregroundColor = .livithColor(.black50)

        if let highlightText = highlightText,
           let range = attributedString.range(of: highlightText) {
            attributedString[range].foregroundColor = .livithColor(.black5)
        }

        return attributedString
    }
}

// MARK: - Triangle Tail

private struct TriangleTail: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.livithColor(.black100)
            .ignoresSafeArea()

        VStack(spacing: 20) {
            LivithCalloutView(
                "회원가입하고 모든 서비스 이용해보세요!",
                highlight: "모든 서비스 이용"
            )

            LivithCalloutView(
                "카카오로 최근에 로그인 했어요",
                highlight: "카카오"
            )

            LivithCalloutView(
                "Apple로 최근에 로그인 했어요",
                highlight: "Apple"
            )
        }
        .padding()
    }
}
