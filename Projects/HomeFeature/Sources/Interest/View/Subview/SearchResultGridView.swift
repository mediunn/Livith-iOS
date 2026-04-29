//
//  SearchResultGridView.swift
//  HomeFeature
//
//  Created by 김진웅 on 12/30/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import DisplaySupport
import LivithDesignSystem
import Domain

struct SearchResultGridView: View {
    let searchResults: [Concert]
    let selectedID: Int?
    let isLoadingMore: Bool
    let onConcertTap: (Int) -> Void
    let onLoadMore: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            resultHeaderText

            ScrollView(showsIndicators: false) {
                if searchResults.isEmpty {
                    emptyView
                } else {
                    gridView
                }
            }
            .padding(.top, 20)
        }
    }
}

// MARK: - Subviews

private extension SearchResultGridView {
    var resultHeaderText: some View {
        (Text("검색 결과 ")
            .foregroundStyle(.livithColor(.black5))
         + Text("\(searchResults.count)건")
            .foregroundStyle(.livithColor(.yellow30))
         + Text("의 정보가 있어요")
            .foregroundStyle(.livithColor(.black5)))
        .notosans(.body2Medium)
    }
    
    var emptyView: some View {
        LivithEmptyView(text: "검색 결과가 없어요")
            .frame(maxWidth: .infinity)
            .containerRelativeFrame(.vertical)
    }
    
    var gridView: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), alignment: .top), count: 3),
            spacing: 32
        ) {
            ForEach(searchResults, id: \.id) { concert in
                concertCard(for: concert)
            }
        }
    }
    
    func concertCard(for concert: Concert) -> some View {
        LivithCard(
            imageURL: concert.posterURL,
            title: ConcertDisplayText.title(for: concert),
            subtitle: ConcertDisplayText.dateRange(for: concert),
            secondaryText: concert.artist,
            badge: .status(text: ConcertDisplayText.statusBadge(for: concert), remainDays: nil),
            isSelected: selectedID == concert.id,
            onTap: { onConcertTap(concert.id) }
        )
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
        .onAppear {
            if concert.id == searchResults.last?.id, !isLoadingMore {
                onLoadMore()
            }
        }
    }
}
