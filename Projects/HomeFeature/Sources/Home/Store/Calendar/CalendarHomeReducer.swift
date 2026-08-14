//
//  CalendarHomeReducer.swift
//  HomeFeature
//
//  Created by 김진웅 on 7/19/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import DIContainer
import Domain
import LivithFoundation

// MARK: - CalendarConcertScope

enum CalendarConcertScope {
    case all
    case my
}

// MARK: - CalendarHomeState

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

// MARK: - CalendarHomeConstants

enum CalendarHomeConstants {
    static let selectionBlockedToastMessage = "예매일 또는 공연일 중 하나는 선택해야 해요."
    static let dayScheduleLoadFailedToastMessage = "일정을 불러오지 못했어요"
    static let loadFailedEmptyMessage = "캘린더를\n불러오지 못했어요"
}

// MARK: - CalendarHomeIntent

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

// MARK: - CalendarHomeReducer

@MainActor
final class CalendarHomeReducer {

    private enum CancelID {
        case fetchMonth
        case fetchDayEvents
    }

    @Injected private var calendarRepository: CalendarRepository

    private let send: (CalendarHomeIntent) -> DiscardableTask
    private var cancellables = [CancelID: Task<Void, Never>]()
    private var monthRequestID = 0
    private var dayEventsRequestID = 0

    init(send: @escaping (CalendarHomeIntent) -> DiscardableTask) {
        self.send = send
    }

    @discardableResult
    func reduce(
        _ intent: CalendarHomeIntent,
        state: inout CalendarHomeState
    ) -> DiscardableTask {
        switch intent {
        case .onAppear:
            if hasFetchRange(state) {
                let showInitialLoading = state.isLoadFailed || state.calendarMonth == nil
                return scheduleFetchMonth(showInitialLoading: showInitialLoading, state: &state)
            }
            state.isInitialLoading = true
            return .none

        case .ticketingDateTapped:
            guard toggleTicketingDateFilter(state: &state) else { return .none }
            return scheduleFetchMonth(showInitialLoading: false, state: &state)

        case .performanceDateTapped:
            guard togglePerformanceDateFilter(state: &state) else { return .none }
            return scheduleFetchMonth(showInitialLoading: false, state: &state)

        case .allConcertsTapped:
            guard state.concertScope != .all else { return .none }
            state.concertScope = .all
            return scheduleFetchMonth(showInitialLoading: false, state: &state)

        case .myConcertsTapped:
            guard state.concertScope != .my else { return .none }
            state.concertScope = .my
            return scheduleFetchMonth(showInitialLoading: false, state: &state)

        case .onSelectionBlockedToastDisappear:
            state.selectionBlockedToastMessage = ""
            return .none

        case .onDayScheduleLoadFailedToastDisappear:
            state.dayScheduleLoadFailedToastMessage = ""
            return .none

        case .dayScheduleRequested(let date):
            performFetchDayEvents(date: date, state: state)
            return .none

        case .dayScheduleModalDismissed:
            state.isDayScheduleModalPresented = false
            return .none

        case .monthChanged(let startDate, let endDate):
            let isSameRange = state.rangeStartDate == startDate && state.rangeEndDate == endDate
            guard !isSameRange || state.calendarMonth == nil || state.isLoadFailed else {
                return .none
            }

            state.isDayScheduleModalPresented = false
            cancellables[.fetchDayEvents]?.cancel()
            dayEventsRequestID += 1

            state.rangeStartDate = startDate
            state.rangeEndDate = endDate
            let showInitialLoading = state.calendarMonth == nil || state.isLoadFailed
            return scheduleFetchMonth(showInitialLoading: showInitialLoading, state: &state)

        case .pullToRefresh:
            state.isInitialLoading = false
            return scheduleFetchMonth(showInitialLoading: false, state: &state)

        case ._fetchMonthResult(let result, let requestID):
            guard requestID == monthRequestID else { return .none }

            state.isInitialLoading = false

            switch result {
            case .success(let month):
                state.calendarMonth = month
                state.isLoadFailed = false
            case .failure(let error):
                guard !isCancellationError(error) else { return .none }
                state.isLoadFailed = true
            }
            return .none

        case ._fetchDayEventsResult(let result, let requestID):
            guard requestID == dayEventsRequestID else { return .none }

            switch result {
            case .success(let schedule):
                state.selectedDayTitle = DateFormatterService.string(
                    from: schedule.date,
                    type: .koreanMonthDayWeekday
                )
                state.dayScheduleEventList = CalendarDayScheduleSorter.sorted(schedule.eventList)
                state.isDayScheduleModalPresented = true
            case .failure(let error):
                guard !isCancellationError(error) else { return .none }
                presentDayScheduleLoadFailedToast(state: &state)
            }
            return .none
        }
    }
}

// MARK: - Helpers

private extension CalendarHomeReducer {
    func hasFetchRange(_ state: CalendarHomeState) -> Bool {
        state.rangeStartDate != nil && state.rangeEndDate != nil
    }

    func scheduleFetchMonth(
        showInitialLoading: Bool,
        state: inout CalendarHomeState
    ) -> DiscardableTask {
        guard let startDate = state.rangeStartDate,
              let endDate = state.rangeEndDate
        else {
            cancellables[.fetchMonth]?.cancel()
            cancellables[.fetchMonth] = nil
            return .none
        }

        cancellables[.fetchMonth]?.cancel()

        monthRequestID += 1
        let requestID = monthRequestID
        let scheduleTypes = scheduleTypeFilterList(state)
        let concertType = concertTypeFilter(state)

        if showInitialLoading {
            state.isInitialLoading = true
            state.isLoadFailed = false
        }

        let task = Task {
            let result = await fetchMonthResult(
                startDate: startDate,
                endDate: endDate,
                scheduleTypes: scheduleTypes,
                concertType: concertType
            )
            guard !Task.isCancelled else { return }
            send(._fetchMonthResult(result, requestID: requestID))
        }
        cancellables[.fetchMonth] = task
        return DiscardableTask(task: task)
    }

    func performFetchDayEvents(date: Date, state: CalendarHomeState) {
        cancellables[.fetchDayEvents]?.cancel()

        dayEventsRequestID += 1
        let requestID = dayEventsRequestID
        let scheduleTypes = scheduleTypeFilterList(state)
        let concertType = concertTypeFilter(state)

        cancellables[.fetchDayEvents] = Task {
            let result = await fetchDayEventsResult(
                date: date,
                scheduleTypes: scheduleTypes,
                concertType: concertType
            )
            send(._fetchDayEventsResult(result, requestID: requestID))
        }
    }

    func fetchMonthResult(
        startDate: String,
        endDate: String,
        scheduleTypes: [CalendarScheduleTypeFilter],
        concertType: CalendarConcertTypeFilter
    ) async -> Result<CalendarMonth, Error> {
        do {
            let month = try await calendarRepository.fetchMonth(
                startDate: startDate,
                endDate: endDate,
                scheduleTypes: scheduleTypes,
                concertType: concertType
            )
            return .success(month)
        } catch {
            return .failure(error)
        }
    }

    func fetchDayEventsResult(
        date: Date,
        scheduleTypes: [CalendarScheduleTypeFilter],
        concertType: CalendarConcertTypeFilter
    ) async -> Result<CalendarDaySchedule, Error> {
        do {
            let schedule = try await calendarRepository.fetchDayEvents(
                date: date,
                scheduleTypes: scheduleTypes,
                concertType: concertType
            )
            return .success(schedule)
        } catch {
            return .failure(error)
        }
    }

    func scheduleTypeFilterList(_ state: CalendarHomeState) -> [CalendarScheduleTypeFilter] {
        var filterList: [CalendarScheduleTypeFilter] = []
        if state.isTicketingDateSelected { filterList.append(.ticketing) }
        if state.isPerformanceDateSelected { filterList.append(.concert) }
        return filterList
    }

    func concertTypeFilter(_ state: CalendarHomeState) -> CalendarConcertTypeFilter {
        switch state.concertScope {
        case .all: return .all
        case .my: return .interest
        }
    }

    func toggleTicketingDateFilter(state: inout CalendarHomeState) -> Bool {
        guard state.isTicketingDateSelected else {
            state.isTicketingDateSelected = true
            return true
        }
        guard state.isPerformanceDateSelected else {
            presentSelectionBlockedToast(state: &state)
            return false
        }
        state.isTicketingDateSelected = false
        return true
    }

    func togglePerformanceDateFilter(state: inout CalendarHomeState) -> Bool {
        guard state.isPerformanceDateSelected else {
            state.isPerformanceDateSelected = true
            return true
        }
        guard state.isTicketingDateSelected else {
            presentSelectionBlockedToast(state: &state)
            return false
        }
        state.isPerformanceDateSelected = false
        return true
    }

    func presentSelectionBlockedToast(state: inout CalendarHomeState) {
        state.selectionBlockedToastMessage = CalendarHomeConstants.selectionBlockedToastMessage
        state.selectionBlockedToastTrigger += 1
    }

    func presentDayScheduleLoadFailedToast(state: inout CalendarHomeState) {
        state.dayScheduleLoadFailedToastMessage = CalendarHomeConstants.dayScheduleLoadFailedToastMessage
        state.dayScheduleLoadFailedToastTrigger += 1
    }

    func isCancellationError(_ error: Error) -> Bool {
        if error is CancellationError { return true }
        if case let calendarError as CalendarError = error, calendarError == .cancelled {
            return true
        }
        return false
    }
}
