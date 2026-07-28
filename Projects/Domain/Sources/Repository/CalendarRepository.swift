//
//  CalendarRepository.swift
//  Domain
//
//  Created by 김진웅 on 7/23/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public protocol CalendarRepository {
    func fetchMonth(
        startDate: String,
        endDate: String,
        scheduleTypes: [CalendarScheduleTypeFilter],
        concertType: CalendarConcertTypeFilter
    ) async throws(CalendarError) -> CalendarMonth

    func fetchDayEvents(
        date: Date,
        scheduleTypes: [CalendarScheduleTypeFilter],
        concertType: CalendarConcertTypeFilter
    ) async throws(CalendarError) -> CalendarDaySchedule
}
