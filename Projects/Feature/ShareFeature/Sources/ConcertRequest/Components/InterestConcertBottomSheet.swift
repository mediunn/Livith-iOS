//
//  InterestConcertBottomSheet.swift
//  ShareFeature
//
//  Created by JinUng41 on 7/9/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

import LivithDesignSystem

struct InterestConcertBottomSheet: View {

    // MARK: - Properties

    private let onDecline: () -> Void
    private let onAccept: () -> Void

    // MARK: - Initializer

    init(
        onDecline: @escaping () -> Void,
        onAccept: @escaping () -> Void
    ) {
        self.onDecline = onDecline
        self.onAccept = onAccept
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()
            
            titleSection
                .padding(.top, 16)
                .padding(.horizontal, 16)

            buttonSection
                .padding(.top, 20)
                .padding(.horizontal, 16)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.livithColor(.black90))
    }
}

// MARK: - UIComponents

private extension InterestConcertBottomSheet {
    var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(Literals.title)
                .notosans(.body1Semibold)
                .foregroundStyle(Color.livithColor(.white100))
                .fixedSize(horizontal: false, vertical: true)

            Text(Literals.subtitle)
                .notosans(.body4Medium)
                .foregroundStyle(Color.livithColor(.black50))
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    var buttonSection: some View {
        HStack(spacing: 10) {
            LivithButton(Literals.decline, variant: .secondary, action: onDecline)

            LivithButton(Literals.accept, variant: .primary, action: onAccept)
        }
    }
}

// MARK: - Constants

extension InterestConcertBottomSheet {
    enum Constants {
        /// 시스템 시트 크롬을 고려해 Figma(220/812)보다 약간 작게 잡음
        static let sheetFraction = 232.0 / 812.0
    }
}

// MARK: - Literals

private extension InterestConcertBottomSheet {
    enum Literals {
        static let title = "콘서트가 등록되면\n관심 콘서트로 자동 등록할까요?"
        static let subtitle = "관심 콘서트로 등록하면 예매 알림,\n콘서트 정보 업데이트 소식을 빠르게 받아볼 수 있어요!"
        static let decline = "괜찮아요"
        static let accept = "등록할래요"
    }
}

// MARK: - Preview

#Preview {
    Color.livithColor(.black100)
        .ignoresSafeArea()
        .livithSheet(
            isPresented: .constant(true),
            detents: [.fraction(InterestConcertBottomSheet.Constants.sheetFraction)]
        ) {
            InterestConcertBottomSheet(onDecline: {}, onAccept: {})
        }
}
