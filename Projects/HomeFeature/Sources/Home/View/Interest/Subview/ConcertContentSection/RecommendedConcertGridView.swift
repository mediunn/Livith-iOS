//
//  RecommendedConcertGridView.swift
//  HomeFeature
//
//  Created by 김진웅 on 2/7/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

import DisplaySupport
import Domain
import LivithDesignSystem

import Amplitude

struct RecommendedConcertGridView: View {

    // MARK: - Properties

    @EnvironmentObject private var homeRouter: HomeRouter

    let concertList: [Concert]

    // MARK: - Body

    var body: some View {
        VStack(spacing: .zero) {
            LivithNavigationView(
                type: .back(
                    title: "취향이 담긴 콘서트",
                    onBack: { homeRouter.pop() }
                )
            )

            gridView
                .padding(16)
        }
        .background(.livithColor(.black100))
    }
}

// MARK: - UIComponents

private extension RecommendedConcertGridView {
    var gridView: some View {
        ScrollView(showsIndicators: false) {
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), alignment: .top), count: 3),
                spacing: 24
            ) {
                ForEach(concertList, id: \.id) { concert in
                    concertCard(for: concert)
                }
            }
        }
    }
    
    func concertCard(for concert: Concert) -> some View {
        LivithCard(
            imageURL: concert.posterURL,
            title: ConcertDisplayHelper.title(for: concert),
            subtitle: ConcertDisplayHelper.dateRange(for: concert),
            secondaryText: concert.artist,
            badge: .status(text: ConcertDisplayHelper.statusBadge(for: concert), remainDays: nil),
            onTap: {
                AmplitudeService.shared.trackEvent(tag: .click(.recommendedConcertCell))
                homeRouter.push(.concertDetail(
                    concertID: concert.id,
                    initialTab: .artistDetail,
                    initialSection: nil
                ))
            }
        )
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
    }
}

// MARK: - Preview

#Preview {
    RecommendedConcertGridView(concertList: [])
}
