//
//  ConcertGridView.swift
//  HomeFeature
//
//  Created by 김진웅 on 12/30/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import DSKit
import HomeDomain

struct ConcertGridView: View {
    let concerts: [Concert]
    let selectedID: Int?
    let isLoadingMore: Bool
    let onConcertTap: (Int) -> Void
    let onLoadMore: () -> Void
    
    var body: some View {
        concerts.isEmpty ? AnyView(emptyView) : AnyView(gridView)
    }
}

// MARK: - Subviews

private extension ConcertGridView {
    var emptyView: some View {
        VStack {
            Spacer()
            
            LivithEmptyView(text: "콘서트 일정이 없어요")
                .frame(maxWidth: .infinity)
            
            Spacer()
        }
    }
    
    var gridView: some View {
        ScrollView(showsIndicators: false) {
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), alignment: .top), count: 3),
                spacing: 32
            ) {
                ForEach(concerts, id: \.id) { concert in
                    concertCard(for: concert)
                }
            }
        }
    }
    
    func concertCard(for concert: Concert) -> some View {
        LivithCard(
            imageURL: concert.posterURL,
            title: concert.title,
            subtitle: concert.startDate,
            secondaryText: concert.artist,
            badge: .status(text: concert.status.statusChipText, remainDays: concert.daysLeft),
            isSelected: selectedID == concert.id
        )
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
        .onAppear {
            if concert.id == concerts.last?.id, !isLoadingMore {
                onLoadMore()
            }
        }
        .onTapGesture {
            onConcertTap(concert.id)
        }
    }
}
