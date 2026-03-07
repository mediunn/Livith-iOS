//
//  RecommendedConcertGridView.swift
//  HomeFeature
//
//  Created by 김진웅 on 2/7/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

import Amplitude
import Domain
import LivithDesignSystem

struct RecommendedConcertGridView: View {
    @Environment(\.homeCoordinator) private var coordinator
    
    let concertList: [Concert]
    
    var body: some View {
        VStack(spacing: .zero) {
            LivithNavigationView(
                type: .back(
                    title: "취향이 담긴 콘서트",
                    onBack: { coordinator?.pop() }
                )
            )
            
            gridView
                .padding(16)
        }
        .background(.livithColor(.black100))
    }
}

// MARK: - Subviews

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
            title: concert.title,
            subtitle: DateFormatter.formatDateRange(from: concert.startDate, to: concert.endDate),
            secondaryText: concert.artist,
            badge: .status(text: concert.status.statusChipText, remainDays: concert.daysLeft),
            onTap: {
                AmplitudeService.shared.trackEvent(tag: .click(.recommendedConcertCell))
                coordinator?.showConcertDetail(concertID: concert.id)
            }
        )
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
    }
}

// MARK: - Preview

#Preview {
    RecommendedConcertGridView(concertList: [])
}
