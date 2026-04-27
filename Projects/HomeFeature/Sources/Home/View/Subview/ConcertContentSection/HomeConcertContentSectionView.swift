//
//  HomeConcertContentSectionView.swift
//  HomeFeature
//
//  Created by 김진웅 on 4/27/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

import Domain
import LivithDesignSystem

struct HomeConcertContentSectionView: View {

    // MARK: - Property

    let nickname: String
    let sectionList: [ConcertSection]
    let recommendedConcertList: [Concert]
    let shouldShowRecommendedConcertSection: Bool
    let onRecommendedConcertTap: (Concert) -> Void
    let onRecommendedSeeAllTap: () -> Void
    let onConcertTap: (Concert) -> Void

    // MARK: - Body

    var body: some View {
        VStack(spacing: .zero) {
            recommendedConcertSection

            concertSection

            Spacer(minLength: 210)
        }
        .background(Color.livithColor(.black100))
    }
}

// MARK: - UIComponents

private extension HomeConcertContentSectionView {
    @ViewBuilder
    var recommendedConcertSection: some View {
        if shouldShowRecommendedConcertSection {
            RecommendedConcertSectionView(
                title: "\(nickname)님의\n취향이 담긴 콘서트",
                concertList: recommendedConcertList,
                onConcertTap: onRecommendedConcertTap,
                onSeeAllTap: onRecommendedSeeAllTap
            )
            .padding(.top, Constants.sectionTopPadding)
            .padding(.leading, Constants.sectionLeadingPadding)
        }
    }

    var concertSection: some View {
        ForEach(sectionList, id: \.id) { section in
            ConcertSectionView(
                concertSection: section,
                onConcertTap: onConcertTap
            )
            .padding(.top, Constants.sectionTopPadding)
            .padding(.leading, Constants.sectionLeadingPadding)
        }
    }
}

// MARK: - Helpers

private extension HomeConcertContentSectionView {
    enum Constants {
        static let sectionTopPadding: CGFloat = 32
        static let sectionLeadingPadding: CGFloat = 16
    }
}
