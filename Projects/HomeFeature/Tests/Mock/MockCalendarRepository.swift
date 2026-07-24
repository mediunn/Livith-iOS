//
//  MockCalendarRepository.swift
//  HomeFeatureTests
//
//  Created by 김진웅 on 7/23/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain

final class MockCalendarRepository: CalendarRepository {
    struct FetchMonthParameters: Equatable {
        let year: Int
        let month: Int
        let scheduleTypeList: [CalendarScheduleTypeFilter]
        let concertType: CalendarConcertTypeFilter
    }

    struct FetchDayEventsParameters: Equatable {
        let date: Date
        let scheduleTypeList: [CalendarScheduleTypeFilter]
        let concertType: CalendarConcertTypeFilter
    }

    var fetchMonthResultQueue: [Result<CalendarMonth, CalendarError>] = []
    var fetchDayEventsResultQueue: [Result<CalendarDaySchedule, CalendarError>] = []

    var fetchMonthCallCount = 0
    var fetchMonthParameterList: [FetchMonthParameters] = []
    var fetchMonthDelayNanoseconds: UInt64 = 0

    var fetchDayEventsCallCount = 0
    var fetchDayEventsParameterList: [FetchDayEventsParameters] = []

    func fetchMonth(
        year: Int,
        month: Int,
        scheduleTypes: [CalendarScheduleTypeFilter],
        concertType: CalendarConcertTypeFilter
    ) async throws(CalendarError) -> CalendarMonth {
        fetchMonthCallCount += 1
        fetchMonthParameterList.append(
            FetchMonthParameters(
                year: year,
                month: month,
                scheduleTypeList: scheduleTypes,
                concertType: concertType
            )
        )

        if fetchMonthDelayNanoseconds > 0 {
            do {
                try await Task.sleep(nanoseconds: fetchMonthDelayNanoseconds)
            } catch {
                throw CalendarError.cancelled
            }

            if Task.isCancelled {
                throw CalendarError.cancelled
            }
        }

        if !fetchMonthResultQueue.isEmpty {
            let result = fetchMonthResultQueue.removeFirst()
            switch result {
            case .success(let month):
                return month
            case .failure(let error):
                throw error
            }
        }

        return CalendarMonth(year: year, month: month, dayList: [])
    }

    func fetchDayEvents(
        date: Date,
        scheduleTypes: [CalendarScheduleTypeFilter],
        concertType: CalendarConcertTypeFilter
    ) async throws(CalendarError) -> CalendarDaySchedule {
        fetchDayEventsCallCount += 1
        fetchDayEventsParameterList.append(
            FetchDayEventsParameters(
                date: date,
                scheduleTypeList: scheduleTypes,
                concertType: concertType
            )
        )

        if !fetchDayEventsResultQueue.isEmpty {
            let result = fetchDayEventsResultQueue.removeFirst()
            switch result {
            case .success(let schedule):
                return schedule
            case .failure(let error):
                throw error
            }
        }

        return CalendarDaySchedule(date: date, eventList: [])
    }
}
