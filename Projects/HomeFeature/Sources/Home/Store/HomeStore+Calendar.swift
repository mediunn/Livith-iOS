//
//  HomeStore+Calendar.swift
//  HomeFeature
//
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain
import LivithFoundation

// MARK: - Calendar

extension HomeStore {
    func reduceCalendar(
        _ intent: CalendarHomeIntent,
        state: inout CalendarHomeState
    ) -> DiscardableTask {
        switch intent {
        case .onAppear:
            if hasCalendarFetchRange(state) {
                let showInitialLoading = state.isLoadFailed || state.calendarMonth == nil
                return scheduleCalendarFetchMonth(showInitialLoading: showInitialLoading, state: &state)
            }
            state.isInitialLoading = true
            return .none

        case .ticketingDateTapped:
            guard toggleTicketingDateFilter(state: &state) else { return .none }
            return scheduleCalendarFetchMonth(showInitialLoading: false, state: &state)

        case .performanceDateTapped:
            guard togglePerformanceDateFilter(state: &state) else { return .none }
            return scheduleCalendarFetchMonth(showInitialLoading: false, state: &state)

        case .allConcertsTapped:
            guard state.concertScope != .all else { return .none }
            state.concertScope = .all
            return scheduleCalendarFetchMonth(showInitialLoading: false, state: &state)

        case .myConcertsTapped:
            guard state.concertScope != .my else { return .none }
            state.concertScope = .my
            return scheduleCalendarFetchMonth(showInitialLoading: false, state: &state)

        case .onSelectionBlockedToastDisappear:
            state.selectionBlockedToastMessage = ""
            return .none

        case .onDayScheduleLoadFailedToastDisappear:
            state.dayScheduleLoadFailedToastMessage = ""
            return .none

        case .dayScheduleRequested(let date):
            performCalendarFetchDayEvents(date: date, state: state)
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
            cancellables[.calendarFetchDayEvents]?.cancel()
            calendarDayEventsRequestID += 1

            state.rangeStartDate = startDate
            state.rangeEndDate = endDate
            let showInitialLoading = state.calendarMonth == nil || state.isLoadFailed
            return scheduleCalendarFetchMonth(showInitialLoading: showInitialLoading, state: &state)

        case .pullToRefresh:
            state.isInitialLoading = false
            return scheduleCalendarFetchMonth(showInitialLoading: false, state: &state)

        case ._fetchMonthResult(let result, let requestID):
            guard requestID == calendarMonthRequestID else { return .none }

            state.isInitialLoading = false

            switch result {
            case .success(let month):
                state.calendarMonth = month
                state.isLoadFailed = false
            case .failure(let error):
                guard !isCalendarCancellationError(error) else { return .none }
                state.isLoadFailed = true
            }
            return .none

        case ._fetchDayEventsResult(let result, let requestID):
            guard requestID == calendarDayEventsRequestID else { return .none }

            switch result {
            case .success(let schedule):
                state.selectedDayTitle = DateFormatterService.string(
                    from: schedule.date,
                    type: .koreanMonthDayWeekday
                )
                state.dayScheduleEventList = CalendarDayScheduleSorter.sorted(schedule.eventList)
                state.isDayScheduleModalPresented = true
            case .failure(let error):
                guard !isCalendarCancellationError(error) else { return .none }
                presentDayScheduleLoadFailedToast(state: &state)
            }
            return .none
        }
    }
}

// MARK: - Calendar Helpers

private extension HomeStore {
    func hasCalendarFetchRange(_ state: CalendarHomeState) -> Bool {
        state.rangeStartDate != nil && state.rangeEndDate != nil
    }

    func scheduleCalendarFetchMonth(
        showInitialLoading: Bool,
        state: inout CalendarHomeState
    ) -> DiscardableTask {
        guard let startDate = state.rangeStartDate,
              let endDate = state.rangeEndDate
        else {
            cancellables[.calendarFetchMonth]?.cancel()
            cancellables[.calendarFetchMonth] = nil
            return .none
        }

        cancellables[.calendarFetchMonth]?.cancel()

        calendarMonthRequestID += 1
        let requestID = calendarMonthRequestID
        let scheduleTypes = calendarScheduleTypeFilterList(state)
        let concertType = calendarConcertTypeFilter(state)

        if showInitialLoading {
            state.isInitialLoading = true
            state.isLoadFailed = false
        }

        let task = Task {
            let result = await fetchCalendarMonthResult(
                startDate: startDate,
                endDate: endDate,
                scheduleTypes: scheduleTypes,
                concertType: concertType
            )
            guard !Task.isCancelled else { return }
            send(.calendar(._fetchMonthResult(result, requestID: requestID)))
        }
        cancellables[.calendarFetchMonth] = task
        return DiscardableTask(task: task)
    }

    func performCalendarFetchDayEvents(date: Date, state: CalendarHomeState) {
        cancellables[.calendarFetchDayEvents]?.cancel()

        calendarDayEventsRequestID += 1
        let requestID = calendarDayEventsRequestID
        let scheduleTypes = calendarScheduleTypeFilterList(state)
        let concertType = calendarConcertTypeFilter(state)

        cancellables[.calendarFetchDayEvents] = Task {
            let result = await fetchCalendarDayEventsResult(
                date: date,
                scheduleTypes: scheduleTypes,
                concertType: concertType
            )
            send(.calendar(._fetchDayEventsResult(result, requestID: requestID)))
        }
    }

    func fetchCalendarMonthResult(
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

    func fetchCalendarDayEventsResult(
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

    func calendarScheduleTypeFilterList(_ state: CalendarHomeState) -> [CalendarScheduleTypeFilter] {
        var filterList: [CalendarScheduleTypeFilter] = []
        if state.isTicketingDateSelected { filterList.append(.ticketing) }
        if state.isPerformanceDateSelected { filterList.append(.concert) }
        return filterList
    }

    func calendarConcertTypeFilter(_ state: CalendarHomeState) -> CalendarConcertTypeFilter {
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

    func isCalendarCancellationError(_ error: Error) -> Bool {
        if error is CancellationError { return true }
        if case let calendarError as CalendarError = error, calendarError == .cancelled {
            return true
        }
        return false
    }
}
