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
                spacing: 16
            ) {
                ForEach(concerts, id: \.id) { concert in
                    concertCard(for: concert)
                }
            }
        }
    }
    
    func concertCard(for concert: Concert) -> some View {
        ConcertDetailCard(
            posterURL: concert.posterURL,
            title: concert.title,
            date: concert.startDate,
            artist: concert.artist,
            status: concert.status.statusChipText,
            remainDays: concert.daysLeft,
            isSelected: selectedID == concert.id
        )
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
        .onTapGesture {
            onConcertTap(concert.id)
        }
        .onAppear {
            if concert.id == concerts.last?.id, !isLoadingMore {
                onLoadMore()
            }
        }
    }
}
