//
//  CalendarDaySchedule.swift
//  Domain
//
//  Created by 김진웅 on 7/23/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

// MARK: - Day Schedule

public struct CalendarDaySchedule: Hashable, Sendable {
    public let date: Date
    public let eventList: [CalendarDayEvent]

    public init(date: Date, eventList: [CalendarDayEvent]) {
        self.date = date
        self.eventList = eventList
    }
}

// MARK: - Day Event Type

public enum CalendarDayEventType: String, Sendable {
    case generalTicketing = "GENERAL_TICKETING"
    case preTicketing = "PRE_TICKETING"
    case addTicketing = "ADD_TICKETING"
    case concert = "CONCERT"
}

// MARK: - Day Event Status

public enum CalendarDayEventStatus: String, Sendable {
    case ongoing = "ONGOING"
    case upcoming = "UPCOMING"
    case completed = "COMPLETED"
    case cancelled = "CANCELLED"

    public var isCancelled: Bool {
        self == .cancelled
    }
}

// MARK: - Day Event

public struct CalendarDayEvent: Hashable, Identifiable, Sendable {
    public let id: CalendarEventID<CalendarDayEventType>
    public let concertID: Int
    public let title: String?
    public let type: CalendarDayEventType
    public let status: CalendarDayEventStatus
    public let time: CalendarEventTime?
    public let detail: CalendarEventDetail?

    public init(
        concertID: Int,
        title: String?,
        type: CalendarDayEventType,
        status: CalendarDayEventStatus,
        time: CalendarEventTime?,
        detail: CalendarEventDetail?
    ) {
        self.id = CalendarEventID(concertID: concertID, type: type)
        self.concertID = concertID
        self.title = title
        self.type = type
        self.status = status
        self.time = time
        self.detail = detail
    }
}
