//
//  EmptyInterestConcertSectionView.swift
//  HomeFeature
//
//  Created by 김진웅 on 12/26/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import LivithDesignSystem

struct EmptyInterestConcertSectionView: View {

    // MARK: - Properties

    @State private var buttonHeight: CGFloat = .zero

    let nickname: String
    let onSettingTap: () -> Void

    // MARK: - Initializer

    init(
        nickname: String,
        onSettingTap: @escaping () -> Void
    ) {
        self.nickname = nickname
        self.onSettingTap = onSettingTap
    }

    // MARK: - Body

    var body: some View {
        headerContentView
            .background {
                UnevenRoundedRectangle(
                    topLeadingRadius: .zero,
                    bottomLeadingRadius: Constants.bottomLeadingCornerRadius,
                    bottomTrailingRadius: .zero,
                    topTrailingRadius: .zero
                )
                .fill(Color.livithColor(.black90))
            }
    }
}

// MARK: - UIComponents

private extension EmptyInterestConcertSectionView {
    var headerContentView: some View {
        HStack(spacing: .zero) {
            VStack(spacing: .zero) {
                Spacer()

                Text("\(nickname)님,\n기다리는\n콘서트가 있나요?")
                    .notosans(.headSemibold)
                    .foregroundStyle(.livithColor(.white100))
                    .padding(.leading, 16)
                    .padding(.bottom, Constants.sectionVerticalPadding)
            }

            Spacer()

            InterestConcertSettingButton(action: onSettingTap)
                .background(buttonHeightReader)
                .onPreferenceChange(InterestConcertButtonHeightPreferenceKey.self) { buttonHeight = $0 }
                .overlay(alignment: .topTrailing) {
                    if buttonHeight > .zero {
                        interestConcertCallout
                            .offset(y: buttonHeight + 12)
                            .allowsHitTesting(false)
                    }
                }
                .padding(.trailing, 16)
                .padding(.vertical, Constants.sectionVerticalPadding)
        }
    }

    var buttonHeightReader: some View {
        GeometryReader { proxy in
            Color.clear
                .preference(
                    key: InterestConcertButtonHeightPreferenceKey.self,
                    value: proxy.size.height
                )
        }
    }

    var interestConcertCallout: some View {
        LivithCalloutView(
            "관심 콘서트 설정하고 공연 일정•셋리스트 정보 빠르게",
            style: .yellow,
            placement: .top(.trailing),
            tailInset: 24
        )
        .lineLimit(1)
        .fixedSize(horizontal: true, vertical: false)
    }
}

// MARK: - Helpers

private struct InterestConcertButtonHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Constants

private extension EmptyInterestConcertSectionView {
    enum Constants {
        static let bottomLeadingCornerRadius: CGFloat = 20
        static let sectionVerticalPadding: CGFloat = 30
    }
}

// MARK: - Preview

#Preview {
    EmptyInterestConcertSectionView(
        nickname: "유지미",
        onSettingTap: {}
    )
}
