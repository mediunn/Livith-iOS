//
//  SearchResultGridView.swift
//  HomeFeature
//
//  Created by 김진웅 on 12/30/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import DSKit
import HomeDomain

struct SearchResultGridView: View {
    let searchResults: [Concert]
    let selectedID: Int?
    let isLoadingMore: Bool
    let onConcertTap: (Int) -> Void
    let onLoadMore: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            resultHeaderText
            
            searchResults.isEmpty ? AnyView(emptyView) : AnyView(gridView)
        }
    }
}

// MARK: - Subviews

private extension SearchResultGridView {
    var resultHeaderText: some View {
        (Text("검색 결과 ")
            .foregroundStyle(.livithColor(.black5))
         + Text("\(searchResults.count)개")
            .foregroundStyle(.livithColor(.yellow30))
         + Text("의 정보가 있어요")
            .foregroundStyle(.livithColor(.black5)))
        .notosans(.body2Medium)
    }
    
    var emptyView: some View {
        VStack {
            Spacer()
            
            LivithEmptyView(text: "검색 결과가 없어요")
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
                ForEach(searchResults, id: \.id) { concert in
                    concertCard(for: concert)
                }
            }
        }
        .padding(.top, 20)
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
            if concert.id == searchResults.last?.id, !isLoadingMore {
                onLoadMore()
            }
        }
    }
}
