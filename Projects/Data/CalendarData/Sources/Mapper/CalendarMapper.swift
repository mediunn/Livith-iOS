//
//  CalendarMapper.swift
//  CalendarData
//
//  Created by 김진웅 on 7/23/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain
import LivithFoundation
import LivithNetworking

struct CalendarMapper {
    func toDomain(from dto: DTO.Response.FetchCalendarMonth) -> CalendarMonth {
        let dayList = dto.days.compactMap(toMonthDay)
        return CalendarMonth(year: dto.year, month: dto.month, dayList: dayList)
    }

    func toDomain(from dto: DTO.Response.FetchCalendarDayEvents) -> CalendarDaySchedule? {
        guard let date = DateFormatterService.date(from: dto.date, type: .dashDate) else {
            return nil
        }
        let eventList = dto.events.compactMap(toDayEvent)
        return CalendarDaySchedule(date: date, eventList: eventList)
    }
}

// MARK: - Month

private extension CalendarMapper {
    func toMonthDay(_ dto: DTO.Response.FetchCalendarMonth.Day) -> CalendarMonthDay? {
        guard let date = DateFormatterService.date(from: dto.date, type: .dashDate) else {
            return nil
        }
        let eventList = dto.events.compactMap(toMonthEvent)
        return CalendarMonthDay(date: date, eventList: eventList)
    }

    func toMonthEvent(_ dto: DTO.Response.FetchCalendarMonth.Event) -> CalendarMonthEvent? {
        guard let type = CalendarMonthEventType(rawValue: dto.type) else {
            return nil
        }
        return CalendarMonthEvent(concertID: dto.id, artist: dto.artist, type: type)
    }
}

// MARK: - Day

private extension CalendarMapper {
    func toDayEvent(_ dto: DTO.Response.FetchCalendarDayEvents.Event) -> CalendarDayEvent? {
        guard let type = CalendarDayEventType(rawValue: dto.type),
              let status = CalendarDayEventStatus(rawValue: dto.status)
        else {
            return nil
        }

        return CalendarDayEvent(
            concertID: dto.id,
            title: dto.title,
            type: type,
            status: status,
            time: parseTime(dto.time),
            detail: parseDetail(dto.detail, aligningWith: type)
        )
    }

    func parseTime(_ raw: String?) -> CalendarEventTime? {
        guard let raw, !raw.isEmpty else { return nil }
        let parts = raw.split(separator: ":")
        guard parts.count == 2,
              let hour = Int(parts[0]),
              let minute = Int(parts[1]),
              (0..<24).contains(hour),
              (0..<60).contains(minute)
        else {
            return nil
        }
        return CalendarEventTime(hour: hour, minute: minute)
    }

    func parseDetail(_ raw: String?, aligningWith type: CalendarDayEventType) -> CalendarEventDetail? {
        guard let raw else { return nil }
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        return CalendarEventDetail.make(text: trimmed, aligningWith: type)
    }
}
