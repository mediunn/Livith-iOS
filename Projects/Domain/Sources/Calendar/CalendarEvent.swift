//
//  CalendarEvent.swift
//  Domain
//
//  Created by 김진웅 on 7/23/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

// MARK: - Event ID

/// 캘린더 일정 행 identity. 같은 콘서트라도 type 또는 time이 다르면 다른 행이다.
public struct CalendarEventID<EventType: Hashable & Sendable>: Hashable, Sendable {
    public let concertID: Int
    public let type: EventType
    public let time: CalendarEventTime?

    public init(concertID: Int, type: EventType, time: CalendarEventTime? = nil) {
        self.concertID = concertID
        self.type = type
        self.time = time
    }
}

// MARK: - Event Time

public struct CalendarEventTime: Hashable, Comparable, Sendable {
    public let hour: Int
    public let minute: Int

    public init(hour: Int, minute: Int) {
        self.hour = hour
        self.minute = minute
    }

    public static func < (lhs: CalendarEventTime, rhs: CalendarEventTime) -> Bool {
        if lhs.hour != rhs.hour {
            return lhs.hour < rhs.hour
        }
        return lhs.minute < rhs.minute
    }
}

// MARK: - Event Detail

public enum CalendarEventDetail: Hashable, Sendable {
    case ticketOffice(String)
    case venue(String)

    public var text: String {
        switch self {
        case .ticketOffice(let value), .venue(let value):
            return value
        }
    }

    public var isTicketOffice: Bool {
        if case .ticketOffice = self { return true }
        return false
    }

    public var isVenue: Bool {
        if case .venue = self { return true }
        return false
    }

    public static func make(text: String, aligningWith type: CalendarDayEventType) -> CalendarEventDetail {
        switch type {
        case .concert:
            return .venue(text)
        case .generalTicketing, .preTicketing, .addTicketing:
            return .ticketOffice(text)
        }
    }
}
