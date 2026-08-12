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

    let scope: CalendarHomeScope

    // MARK: - Body

    var body: some View {
        HStack {
            dateFilterChips

            Spacer()

            CalendarScopeFilterView(
                selectedScope: scope.state.concertScope,
                onAllConcertsTap: {
                    AmplitudeService.shared.trackEvent(tag: .click(.calendarToggleAllConcert))
                    scope.send(.allConcertsTapped)
                },
                onMyConcertsTap: {
                    AmplitudeService.shared.trackEvent(tag: .click(.calendarToggleMyConcerts))
                    scope.send(.myConcertsTapped)
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
                isSelected: scope.state.isTicketingDateSelected,
                onTap: {
                    AmplitudeService.shared.trackEvent(tag: .click(.calendarChipBookingDate))
                    scope.send(.ticketingDateTapped)
                }
            )

            CalendarDateFilterChipView(
                kind: .performance,
                isSelected: scope.state.isPerformanceDateSelected,
                onTap: {
                    AmplitudeService.shared.trackEvent(tag: .click(.calendarChipConcertDate))
                    scope.send(.performanceDateTapped)
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
