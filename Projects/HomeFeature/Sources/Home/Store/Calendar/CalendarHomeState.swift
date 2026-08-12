//
//  CalendarHomeState.swift
//  HomeFeature
//
//  Created by 김진웅 on 7/19/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain

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
    var rangeStartDate: String?
    var rangeEndDate: String?
    var calendarMonth: CalendarMonth?
    var isInitialLoading: Bool = false
    var isLoadFailed: Bool = false
    var selectionBlockedToastMessage: String = ""
    var selectionBlockedToastTrigger: Int = 0
    var dayScheduleLoadFailedToastMessage: String = ""
    var dayScheduleLoadFailedToastTrigger: Int = 0
    var isDayScheduleModalPresented: Bool = false
    var selectedDayTitle: String = ""
    var dayScheduleEventList: [CalendarDayEvent] = []
}

// MARK: - Constants

enum CalendarHomeConstants {
    static let selectionBlockedToastMessage = "예매일 또는 공연일 중 하나는 선택해야 해요."
    static let dayScheduleLoadFailedToastMessage = "일정을 불러오지 못했어요"
    static let loadFailedEmptyMessage = "캘린더를\n불러오지 못했어요"
}

// MARK: - Intent

enum CalendarHomeIntent {
    case onAppear
    case ticketingDateTapped
    case performanceDateTapped
    case allConcertsTapped
    case myConcertsTapped
    case onSelectionBlockedToastDisappear
    case onDayScheduleLoadFailedToastDisappear
    case dayScheduleRequested(date: Date)
    case dayScheduleModalDismissed
    case monthChanged(startDate: String, endDate: String)
    case pullToRefresh
    case _fetchMonthResult(Result<CalendarMonth, Error>, requestID: Int)
    case _fetchDayEventsResult(Result<CalendarDaySchedule, Error>, requestID: Int)
}
