//
//  ConcertGridView.swift
//  HomeFeature
//
//  Created by 김진웅 on 12/30/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import LivithDesignSystem
import Domain
import LivithFoundation

struct ConcertGridView: View {
    let concerts: [Concert]
    let selectedID: Int?
    let isLoadingMore: Bool
    let onConcertTap: (Int) -> Void
    let onLoadMore: () -> Void
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            if concerts.isEmpty {
                emptyView
            } else {
                gridView
            }
        }
    }
}

// MARK: - Subviews

private extension ConcertGridView {
    var emptyView: some View {
        LivithEmptyView(text: "콘서트 일정이 없어요")
            .frame(maxWidth: .infinity)
            .containerRelativeFrame(.vertical)
    }
    
    var gridView: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), alignment: .top), count: 3),
            spacing: 32
        ) {
            ForEach(concerts, id: \.id) { concert in
                concertCard(for: concert)
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
            isSelected: selectedID == concert.id,
            onTap: { onConcertTap(concert.id) }
        )
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
        .onAppear {
            if concert.id == concerts.last?.id, !isLoadingMore {
                onLoadMore()
            }
        }
    }
}
