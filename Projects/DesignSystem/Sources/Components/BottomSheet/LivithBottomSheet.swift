//
//  LivithBottomSheet.swift
//  LivithDesignSystem
//
//  Created by Youjin Lee on 1/6/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

// MARK: - Handle Style

public enum LivithBottomSheetHandleStyle {
    case dark
    case light

    var color: Color {
        switch self {
        case .dark:
            return Color.livithColor(.black80)
        case .light:
            return Color.livithColor(.white100)
        }
    }
}

// MARK: - LivithBottomSheet

public struct LivithBottomSheet<Content: View>: View {

    // MARK: - Property

    private let handleStyle: LivithBottomSheetHandleStyle
    private let handleWidth: CGFloat
    private let backgroundColor: Color
    private let cornerRadius: CGFloat
    private let content: Content

    // MARK: - Initializer

    public init(
        handleStyle: LivithBottomSheetHandleStyle = .dark,
        handleWidth: CGFloat = 60,
        backgroundColor: Color = .livithColor(.black90),
        cornerRadius: CGFloat = 20,
        @ViewBuilder content: () -> Content
    ) {
        self.handleStyle = handleStyle
        self.handleWidth = handleWidth
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.content = content()
    }

    // MARK: - Body

    public var body: some View {
        VStack(spacing: 0) {
            handleBar
                .padding(.top, 10)

            content
        }
        .background(backgroundColor)
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: cornerRadius,
                topTrailingRadius: cornerRadius
            )
        )
    }
}

// MARK: - Subviews

private extension LivithBottomSheet {
    var handleBar: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(handleStyle.color)
            .frame(width: handleWidth, height: 6)
    }
}

// MARK: - Preview

#Preview("Dark Handle") {
    ZStack {
        Color.livithColor(.black100)
            .ignoresSafeArea()

        VStack {
            Spacer()

            LivithBottomSheet(handleStyle: .dark) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("바텀시트 컨텐츠")
                        .notosans(.body2Semibold)
                        .foregroundStyle(Color.livithColor(.white100))

                    Text("여기에 원하는 컨텐츠를 넣으세요")
                        .notosans(.body4Regular)
                        .foregroundStyle(Color.livithColor(.black50))
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
        }
    }
}

#Preview("Light Handle") {
    ZStack {
        Color.livithColor(.black100)
            .ignoresSafeArea()

        VStack {
            Spacer()

            LivithBottomSheet(handleStyle: .light, handleWidth: 132) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("액션 메뉴")
                        .notosans(.body2Semibold)
                        .foregroundStyle(Color.livithColor(.white100))
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
        }
    }
}
