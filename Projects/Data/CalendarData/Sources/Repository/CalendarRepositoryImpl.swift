//
//  CalendarRepositoryImpl.swift
//  CalendarData
//
//  Created by 김진웅 on 7/23/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain
import LivithFoundation
import LivithNetworking

struct CalendarRepositoryImpl: CalendarRepository {
    private let networkClient: NetworkClient
    private let mapper: CalendarMapper = .init()
    private let errorMapper: CalendarErrorMapper = .init()

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    func fetchMonth(
        year: Int,
        month: Int,
        scheduleTypes: [CalendarScheduleTypeFilter],
        concertType: CalendarConcertTypeFilter
    ) async throws(CalendarError) -> CalendarMonth {
        do {
            let response: DTO.Response.FetchCalendarMonth = try await networkClient.request(
                CalendarAPI.fetchMonth(
                    year: year,
                    month: month,
                    scheduleTypes: scheduleTypes.map(\.rawValue),
                    concertType: concertType.rawValue
                )
            )
            return mapper.toDomain(from: response)
        } catch {
            throw errorMapper.mapToCalendarError(error)
        }
    }

    func fetchDayEvents(
        date: Date,
        scheduleTypes: [CalendarScheduleTypeFilter],
        concertType: CalendarConcertTypeFilter
    ) async throws(CalendarError) -> CalendarDaySchedule {
        do {
            let dateString = DateFormatterService.string(from: date, type: .dashDate)
            let response: DTO.Response.FetchCalendarDayEvents = try await networkClient.request(
                CalendarAPI.fetchDayEvents(
                    date: dateString,
                    scheduleTypes: scheduleTypes.map(\.rawValue),
                    concertType: concertType.rawValue
                )
            )
            guard let schedule = mapper.toDomain(from: response) else {
                throw CalendarError.invalidResponse
            }
            return schedule
        } catch let error as CalendarError {
            throw error
        } catch {
            throw errorMapper.mapToCalendarError(error)
        }
    }
}
