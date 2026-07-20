//
//  CalendarHomeStore.swift
//  HomeFeature
//
//  Created by 김진웅 on 7/19/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

// MARK: - Concert Scope

enum CalendarConcertScope {
    case all
    case my
}

// MARK: - State

struct CalendarHomeState {
    var isTicketingDateSelected: Bool = true
    var isPerformanceDateSelected: Bool = true
    var concertScope: CalendarConcertScope = .all
    var isLoadFailed: Bool = true
    var selectionBlockedToastMessage: String = ""
    var selectionBlockedToastTrigger: Int = 0
    var isDayScheduleModalPresented: Bool = false
    var selectedDayTitle: String = ""
    var dayScheduleItemList: [CalendarDayScheduleItem] = []
}

// MARK: - Intent

enum CalendarHomeIntent {
    case ticketingDateTapped
    case performanceDateTapped
    case allConcertsTapped
    case myConcertsTapped
    case onSelectionBlockedToastDisappear
    case dayScheduleModalOpened(dayTitle: String, itemList: [CalendarDayScheduleItem])
    case dayScheduleModalDismissed
}

// MARK: - Store

@MainActor
final class CalendarHomeStore: ObservableObject {

    enum Constants {
        static let selectionBlockedToastMessage = "예매일 또는 공연일 중 하나는 선택해야 해요."
        static let loadFailedEmptyMessage = "캘린더를\n불러오지 못했어요"
    }

    @Published private(set) var state: CalendarHomeState = .init()

    func send(_ intent: CalendarHomeIntent) {
        switch intent {
        case .ticketingDateTapped:
            toggleDateFilter(
                isSelected: state.isTicketingDateSelected,
                otherIsSelected: state.isPerformanceDateSelected,
                setSelected: { state.isTicketingDateSelected = $0 }
            )

        case .performanceDateTapped:
            toggleDateFilter(
                isSelected: state.isPerformanceDateSelected,
                otherIsSelected: state.isTicketingDateSelected,
                setSelected: { state.isPerformanceDateSelected = $0 }
            )

        case .allConcertsTapped:
            state.concertScope = .all

        case .myConcertsTapped:
            state.concertScope = .my

        case .onSelectionBlockedToastDisappear:
            state.selectionBlockedToastMessage = ""

        case .dayScheduleModalOpened(let dayTitle, let itemList):
            state.selectedDayTitle = dayTitle
            state.dayScheduleItemList = CalendarDayScheduleSorter.sorted(itemList)
            state.isDayScheduleModalPresented = true

        case .dayScheduleModalDismissed:
            state.isDayScheduleModalPresented = false
        }
    }

    func performRefresh() async {
        // TODO: WebView URL 재로드 연동
    }
}

// MARK: - Private Helpers

private extension CalendarHomeStore {
    func toggleDateFilter(
        isSelected: Bool,
        otherIsSelected: Bool,
        setSelected: (Bool) -> Void
    ) {
        guard isSelected else {
            setSelected(true)
            return
        }

        guard otherIsSelected else {
            presentSelectionBlockedToast()
            return
        }

        setSelected(false)
    }

    func presentSelectionBlockedToast() {
        state.selectionBlockedToastMessage = Constants.selectionBlockedToastMessage
        state.selectionBlockedToastTrigger += 1
    }
}
