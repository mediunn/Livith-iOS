//
//  CalendarMonth.swift
//  Domain
//
//  Created by 김진웅 on 7/23/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

// MARK: - Month

public struct CalendarMonth: Hashable, Sendable {
    public let dayList: [CalendarMonthDay]

    public init(dayList: [CalendarMonthDay]) {
        self.dayList = dayList
    }
}

// MARK: - Month Day

public struct CalendarMonthDay: Hashable, Identifiable, Sendable {
    public let date: Date
    public let eventList: [CalendarMonthEvent]

    public var id: Date { date }

    public init(date: Date, eventList: [CalendarMonthEvent]) {
        self.date = date
        self.eventList = eventList
    }
}

// MARK: - Month Event Type

public enum CalendarMonthEventType: String, Sendable {
    case ticketing = "TICKETING"
    case concert = "CONCERT"
}

// MARK: - Month Event

public struct CalendarMonthEvent: Hashable, Identifiable, Sendable {
    public let id: CalendarEventID<CalendarMonthEventType>
    public let concertID: Int
    public let artist: String
    public let type: CalendarMonthEventType

    public init(concertID: Int, artist: String, type: CalendarMonthEventType) {
        self.id = CalendarEventID(concertID: concertID, type: type)
        self.concertID = concertID
        self.artist = artist
        self.type = type
    }
}
