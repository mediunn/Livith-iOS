//
//  CalendarFilterBarView.swift
//  HomeFeature
//
//  Created by 김진웅 on 7/19/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

struct CalendarFilterBarView: View {

    // MARK: - Properties

    @ObservedObject var store: CalendarHomeStore

    // MARK: - Body

    var body: some View {
        HStack {
            dateFilterChips

            Spacer()

            CalendarScopeFilterView(
                selectedScope: store.state.concertScope,
                onAllConcertsTap: { store.send(.allConcertsTapped) },
                onMyConcertsTap: { store.send(.myConcertsTapped) }
            )
        }
        .padding(Layout.contentPadding)
    }
}

// MARK: - UIComponents

private extension CalendarFilterBarView {
    var dateFilterChips: some View {
        HStack(spacing: Layout.chipSpacing) {
            CalendarDateFilterChipView(
                kind: .ticketing,
                isSelected: store.state.isTicketingDateSelected,
                onTap: { store.send(.ticketingDateTapped) }
            )

            CalendarDateFilterChipView(
                kind: .performance,
                isSelected: store.state.isPerformanceDateSelected,
                onTap: { store.send(.performanceDateTapped) }
            )
        }
    }
}

// MARK: - Layout

private extension CalendarFilterBarView {
    enum Layout {
        static let contentPadding: CGFloat = 16
        static let chipSpacing: CGFloat = 6
    }
}
