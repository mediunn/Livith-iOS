//
//  InterestConcertSelectionGridView.swift
//  HomeFeature
//
//  Created by 김진웅 on 4/20/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

import LivithDesignSystem
import Domain
import LivithFoundation

struct InterestConcertSelectionGridView: View {
    let concertList: [Concert]
    let selectedConcertIDList: [Int]
    let onConcertTap: (Int) -> Void
    let onScroll: () -> Void

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
        }
        .padding(.top, Constants.gridTopPadding)
        .padding(.horizontal, Constants.horizontalPadding)
        .padding(.bottom, Constants.gridBottomPadding)
    }

    func concertCard(for concert: Concert) -> some View {
        LivithCard(
            imageURL: concert.posterURL,
            title: concert.title,
            subtitle: DateFormatter.formatDateRange(from: concert.startDate, to: concert.endDate),
            secondaryText: concert.artist,
            badge: .status(text: concert.status.statusChipText, remainDays: concert.daysLeft),
            isSelected: selectedConcertIDList.contains(concert.id),
            onTap: { onConcertTap(concert.id) }
        )
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
        static let horizontalPadding: CGFloat = 16
        static let gridTopPadding: CGFloat = 20
        static let gridBottomPadding: CGFloat = 16
    }
}
