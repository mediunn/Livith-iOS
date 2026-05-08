//
//  InterestConcertSelectionGridView.swift
//  HomeFeature
//
//  Created by 김진웅 on 4/20/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

import DisplaySupport
import LivithDesignSystem
import Domain

struct InterestConcertSelectionGridView: View {
    let concertList: [Concert]
    let selectedConcertIDList: [Int]
    let isLoadingMore: Bool
    let onConcertTap: (Int) -> Void
    let onScroll: () -> Void
    let onLoadMore: () -> Void

    var body: some View {
        ScrollView(showsIndicators: false) {
            if concertList.isEmpty {
                emptyView
            } else {
                gridView
            }
        }
        .scrollDismissesKeyboard(.immediately)
        .simultaneousGesture(
            DragGesture().onChanged { _ in
                onScroll()
            }
        )
    }
}

private extension InterestConcertSelectionGridView {
    var emptyView: some View {
        LivithEmptyView(text: "검색 결과가 없어요")
            .frame(maxWidth: .infinity)
            .containerRelativeFrame(.vertical)
    }

    var gridView: some View {
        LazyVGrid(
            columns: gridItems,
            spacing: Constants.gridSpacing
        ) {
            ForEach(concertList) { concert in
                concertCard(for: concert)
            }

            if isLoadingMore {
                ProgressView()
                    .tint(Color.livithColor(.white100))
                    .gridCellColumns(Constants.gridColumns)
                    .padding(.vertical, 16)
            }
        }
        .padding(.top, 20)
        .padding(.horizontal, 16)
        .padding(.bottom, Constants.bottomContentPadding)
    }

    func concertCard(for concert: Concert) -> some View {
        LivithCard(
            imageURL: concert.posterURL,
            title: ConcertDisplayText.title(for: concert),
            subtitle: ConcertDisplayText.dateRange(for: concert),
            secondaryText: concert.artist,
            badge: .status(text: ConcertDisplayText.statusBadge(for: concert), remainDays: nil),
            isSelected: selectedConcertIDList.contains(concert.id),
            onTap: { onConcertTap(concert.id) }
        )
        .onAppear {
            if concert.id == concertList.last?.id {
                onLoadMore()
            }
        }
    }
}

private extension InterestConcertSelectionGridView {
    var gridItems: [GridItem] {
        Array(
            repeating: GridItem(.flexible(), spacing: Constants.gridSpacing, alignment: .top),
            count: Constants.gridColumns
        )
    }
}

private extension InterestConcertSelectionGridView {
    enum Constants {
        static let gridColumns = 3
        static let gridSpacing: CGFloat = 12
        static let bottomContentPadding: CGFloat = 210
    }
}
