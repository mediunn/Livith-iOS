//
//  CalendarHomeStore.swift
//  HomeFeature
//
//  Created by 김진웅 on 7/19/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import DIContainer
import Domain
import LivithFoundation

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
    var selectedYear: Int = CalendarHomeState.currentYearMonth.year
    var selectedMonth: Int = CalendarHomeState.currentYearMonth.month
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

    static var currentYearMonth: (year: Int, month: Int) {
        let components = Calendar.current.dateComponents([.year, .month], from: Date())
        return (components.year ?? 2_026, components.month ?? 1)
    }
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
    case _fetchMonthResult(Result<CalendarMonth, Error>, requestID: Int)
    case _fetchDayEventsResult(Result<CalendarDaySchedule, Error>, requestID: Int)
}

// MARK: - Store

@MainActor
final class CalendarHomeStore: ObservableObject {

    enum Constants {
        static let selectionBlockedToastMessage = "예매일 또는 공연일 중 하나는 선택해야 해요."
        static let dayScheduleLoadFailedToastMessage = "일정을 불러오지 못했어요"
        static let loadFailedEmptyMessage = "캘린더를\n불러오지 못했어요"
    }

    @Published private(set) var state: CalendarHomeState = .init()

    @Injected private var calendarRepository: CalendarRepository

    private enum CancelID {
        case fetchMonth
        case fetchDayEvents
    }

    private var cancellables = [CancelID: Task<Void, Never>]()
    private var monthRequestID = 0
    private var dayEventsRequestID = 0

    func send(_ intent: CalendarHomeIntent) {
        switch intent {
        case .onAppear:
            performFetchMonth(showInitialLoading: true)

        case .ticketingDateTapped:
            let didChange = toggleDateFilter(
                isSelected: state.isTicketingDateSelected,
                otherIsSelected: state.isPerformanceDateSelected,
                setSelected: { state.isTicketingDateSelected = $0 }
            )
            if didChange {
                performFetchMonth(showInitialLoading: false)
            }

        case .performanceDateTapped:
            let didChange = toggleDateFilter(
                isSelected: state.isPerformanceDateSelected,
                otherIsSelected: state.isTicketingDateSelected,
                setSelected: { state.isPerformanceDateSelected = $0 }
            )
            if didChange {
                performFetchMonth(showInitialLoading: false)
            }

        case .allConcertsTapped:
            guard state.concertScope != .all else { return }

            state.concertScope = .all
            performFetchMonth(showInitialLoading: false)

        case .myConcertsTapped:
            guard state.concertScope != .my else { return }

            state.concertScope = .my
            performFetchMonth(showInitialLoading: false)

        case .onSelectionBlockedToastDisappear:
            state.selectionBlockedToastMessage = ""

        case .onDayScheduleLoadFailedToastDisappear:
            state.dayScheduleLoadFailedToastMessage = ""

        case .dayScheduleRequested(let date):
            performFetchDayEvents(date: date)

        case .dayScheduleModalDismissed:
            state.isDayScheduleModalPresented = false

        case ._fetchMonthResult(let result, let requestID):
            guard requestID == monthRequestID else { return }

            state.isInitialLoading = false

            switch result {
            case .success(let month):
                state.calendarMonth = month
                state.isLoadFailed = false
            case .failure(let error):
                guard !isCancellationError(error) else { return }

                state.isLoadFailed = true
            }

        case ._fetchDayEventsResult(let result, let requestID):
            guard requestID == dayEventsRequestID else { return }

            switch result {
            case .success(let schedule):
                state.selectedDayTitle = DateFormatterService.string(from: schedule.date, type: .koreanMonthDayWeekday)
                state.dayScheduleEventList = CalendarDayScheduleSorter.sorted(schedule.eventList)
                state.isDayScheduleModalPresented = true
            case .failure(let error):
                guard !isCancellationError(error) else { return }

                presentDayScheduleLoadFailedToast()
            }
        }
    }

    func performRefresh() async {
        let showInitialLoading = state.isLoadFailed || state.calendarMonth == nil
        cancellables[.fetchMonth]?.cancel()

        monthRequestID += 1
        let requestID = monthRequestID

        if showInitialLoading {
            state.isInitialLoading = true
        }

        let result = await fetchMonthResult()
        send(._fetchMonthResult(result, requestID: requestID))
    }
}

// MARK: - Private Helpers

private extension CalendarHomeStore {
    func performFetchMonth(showInitialLoading: Bool) {
        cancellables[.fetchMonth]?.cancel()

        monthRequestID += 1
        let requestID = monthRequestID

        if showInitialLoading {
            state.isInitialLoading = true
        }

        cancellables[.fetchMonth] = Task {
            let result = await fetchMonthResult()
            send(._fetchMonthResult(result, requestID: requestID))
        }
    }

    func performFetchDayEvents(date: Date) {
        cancellables[.fetchDayEvents]?.cancel()

        dayEventsRequestID += 1
        let requestID = dayEventsRequestID

        cancellables[.fetchDayEvents] = Task {
            let result = await fetchDayEventsResult(date: date)
            send(._fetchDayEventsResult(result, requestID: requestID))
        }
    }

    func fetchMonthResult() async -> Result<CalendarMonth, Error> {
        do {
            let month = try await calendarRepository.fetchMonth(
                year: state.selectedYear,
                month: state.selectedMonth,
                scheduleTypes: scheduleTypeFilterList(),
                concertType: concertTypeFilter()
            )
            return .success(month)
        } catch {
            return .failure(error)
        }
    }

    func fetchDayEventsResult(date: Date) async -> Result<CalendarDaySchedule, Error> {
        do {
            let schedule = try await calendarRepository.fetchDayEvents(
                date: date,
                scheduleTypes: scheduleTypeFilterList(),
                concertType: concertTypeFilter()
            )
            return .success(schedule)
        } catch {
            return .failure(error)
        }
    }

    func scheduleTypeFilterList() -> [CalendarScheduleTypeFilter] {
        var filterList: [CalendarScheduleTypeFilter] = []

        if state.isTicketingDateSelected {
            filterList.append(.ticketing)
        }
        if state.isPerformanceDateSelected {
            filterList.append(.concert)
        }

        return filterList
    }

    func concertTypeFilter() -> CalendarConcertTypeFilter {
        switch state.concertScope {
        case .all:
            return .all
        case .my:
            return .interest
        }
    }

    @discardableResult
    func toggleDateFilter(
        isSelected: Bool,
        otherIsSelected: Bool,
        setSelected: (Bool) -> Void
    ) -> Bool {
        guard isSelected else {
            setSelected(true)
            return true
        }

        guard otherIsSelected else {
            presentSelectionBlockedToast()
            return false
        }

        setSelected(false)
        return true
    }

    func presentSelectionBlockedToast() {
        state.selectionBlockedToastMessage = Constants.selectionBlockedToastMessage
        state.selectionBlockedToastTrigger += 1
    }

    func presentDayScheduleLoadFailedToast() {
        state.dayScheduleLoadFailedToastMessage = Constants.dayScheduleLoadFailedToastMessage
        state.dayScheduleLoadFailedToastTrigger += 1
    }

    func isCancellationError(_ error: Error) -> Bool {
        if error is CancellationError {
            return true
        }

        if case let calendarError as CalendarError = error, calendarError == .cancelled {
            return true
        }

        return false
    }
}
