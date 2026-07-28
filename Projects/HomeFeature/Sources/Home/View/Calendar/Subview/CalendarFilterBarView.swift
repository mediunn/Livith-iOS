//
//  CalendarFilterBarView.swift
//  HomeFeature
//
//  Created by 김진웅 on 7/19/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

import Amplitude

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
                onAllConcertsTap: {
                    AmplitudeService.shared.trackEvent(tag: .click(.calendarToggleAllConcert))
                    store.send(.allConcertsTapped)
                },
                onMyConcertsTap: {
                    AmplitudeService.shared.trackEvent(tag: .click(.calendarToggleMyConcerts))
                    store.send(.myConcertsTapped)
                }
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
                onTap: {
                    AmplitudeService.shared.trackEvent(tag: .click(.calendarChipBookingDate))
                    store.send(.ticketingDateTapped)
                }
            )

            CalendarDateFilterChipView(
                kind: .performance,
                isSelected: store.state.isPerformanceDateSelected,
                onTap: {
                    AmplitudeService.shared.trackEvent(tag: .click(.calendarChipConcertDate))
                    store.send(.performanceDateTapped)
                }
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
